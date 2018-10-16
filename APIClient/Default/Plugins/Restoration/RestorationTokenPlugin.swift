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
    
    /// Callback to send a restore request
    public var restorationResultProvider: ((@escaping (Result<TokenType>) -> Void) -> Void)?

    private let credentialProvider: AccessCredentialsProvider

    public init(credentialProvider: AccessCredentialsProvider) {
        self.credentialProvider = credentialProvider
    }

    public func canResolve(_ error: Error) -> Bool {
        if let error = error as? NetworkError, case .unauthorized = error {
            return true
        }
        return false
    }

    public func resolve(_ error: Error, onResolved: @escaping (Bool) -> Void) {
        guard let error = error as? NetworkError, case .unauthorized = error else {
            onResolved(false)
            return
        }

        guard credentialProvider.exchangeToken != nil && restorationResultProvider != nil else {
            credentialProvider.invalidate()
            onResolved(false)
            return
        }
 
        restorationResultProvider?() { [weak self] result in
            guard let value = result.value else {
                self?.credentialProvider.invalidate()
                onResolved(false)
                return
            }

            self?.credentialProvider.commitCredentialsUpdate { provider in
                provider.accessToken = value.accessToken
                provider.exchangeToken = value.exchangeToken
                onResolved(true)
            }
        }
    }
}
