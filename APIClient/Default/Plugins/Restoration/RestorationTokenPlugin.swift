//
//  RestorationTokenPlugin.swift
//  APIClient
//
//  Created by Vodolazkyi Anton on 9/24/18.
//

import Foundation

public protocol TokenType {
    
    var accessToken: String { get set }
    var exchangeToken: String { get set }
}

/// The plugin to restore the token can be used as the requestor's credential provider
public class RestorationTokenPlugin: PluginType {
    
    /// callback that provides result of request made to restore the session; captured
    public var restorationResultProvider: ((@escaping (Result<TokenType>) -> Void) -> Void)?
    
    let shouldHaltRequestsTillResolve: Bool
    weak var delegate: RestorationTokenPluginDelegate?
    
    private var inProgress = false
    private let credentialProvider: AccessCredentialsProvider
    private let authErrorResolving: AuthErrorResolving
    private var queue: [(Bool) -> Void] = []
    /// - Parameters:
    ///   - credentialProvider: an access credentials provider that provides all required data to restore token; captured
    ///   - shouldHaltRequestsTillResolve: indicates whether APIClient should halt all passing requests in case one of them failed with `unathorized` error and restart them
    ///                                    works only with `AuthorizableRequest`s
    ///   - authErrorResolving: an optional callback that allows you to determine whether a given error is `unauthorized` one
    public init(credentialProvider: AccessCredentialsProvider, shouldHaltRequestsTillResolve: Bool = true, authErrorResolving: AuthErrorResolving? = nil) {
        self.credentialProvider = credentialProvider
        self.shouldHaltRequestsTillResolve = shouldHaltRequestsTillResolve
        self.authErrorResolving = authErrorResolving ?? { error in
            if let error = error as? NetworkError, case .unauthorized = error {
                return true
            }
            
            return false
        }
    }

    public func canResolve(_ error: Error) -> Bool {
        if authErrorResolving(error) {
            delegate?.reachUnauthorizedError()
            return true
        }
        return inProgress
    }

    public func resolve(_ error: Error, onResolved: @escaping (Bool) -> Void) {
        if inProgress {
            queue.append(onResolved)
        } else {
            guard authErrorResolving(error) else {
                delegate?.failedToRestore()
                onResolved(false)
                queue.forEach { $0(false) }
                queue.removeAll()
                return
            }

            guard credentialProvider.exchangeToken != nil && restorationResultProvider != nil else {
                credentialProvider.invalidate()
                delegate?.failedToRestore()
                onResolved(false)
                queue.forEach { $0(false) }
                queue.removeAll()
                return
            }
     
            inProgress = true
            restorationResultProvider? { [weak self] result in
                self?.inProgress = false

                guard let value = result.value else {
                    self?.credentialProvider.invalidate()
                    self?.delegate?.failedToRestore()
                    onResolved(false)
                    self?.queue.forEach { $0(false) }
                    self?.queue.removeAll()
                    return
                }

                self?.credentialProvider.commitCredentialsUpdate { provider in
                    provider.accessToken = value.accessToken
                    provider.exchangeToken = value.exchangeToken
                    self?.delegate?.restored()
                    onResolved(true)
                    self?.queue.forEach { $0(true) }
                    self?.queue.removeAll()
                }
            }
        }
    }
}

protocol RestorationTokenPluginDelegate: class {
    
    func reachUnauthorizedError()
    func restored()
    func failedToRestore()
}
