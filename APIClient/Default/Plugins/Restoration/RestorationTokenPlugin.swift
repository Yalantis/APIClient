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
    
    private let credentialProvider: AccessCredentialsProvider

    /// - Parameters:
    ///   - credentialProvider: an access credentials provider that provides all required data to restore token; captured
    ///   - shouldHaltRequestsTillResolve: indicates whether APIClient should halt all passing requests in case one of them failed with `unathorized` error and restart them
    public init(credentialProvider: AccessCredentialsProvider, shouldHaltRequestsTillResolve: Bool = true) {
        self.credentialProvider = credentialProvider
        self.shouldHaltRequestsTillResolve = shouldHaltRequestsTillResolve
    }

    public func canResolve(_ error: Error) -> Bool {
        if let error = error as? NetworkError, case .unauthorized = error {
            delegate?.reachUnauthorizedError()
            return true
        }
        return false
    }

    public func resolve(_ error: Error, onResolved: @escaping (Bool) -> Void) {
        guard let error = error as? NetworkError, case .unauthorized = error else {
            delegate?.failedToRestore()
            onResolved(false)
            return
        }

        guard credentialProvider.exchangeToken != nil && restorationResultProvider != nil else {
            credentialProvider.invalidate()
            delegate?.failedToRestore()
            onResolved(false)
            return
        }
 
        restorationResultProvider? { [weak self] result in
            guard let value = result.value else {
                self?.credentialProvider.invalidate()
                self?.delegate?.failedToRestore()
                onResolved(false)
                return
            }

            self?.credentialProvider.commitCredentialsUpdate { provider in
                provider.accessToken = value.accessToken
                provider.exchangeToken = value.exchangeToken
                self?.delegate?.restored()
                onResolved(true)
            }
        }
    }
}

protocol RestorationTokenPluginDelegate: class {
    
    func reachUnauthorizedError()
    func restored()
    func failedToRestore()
}
