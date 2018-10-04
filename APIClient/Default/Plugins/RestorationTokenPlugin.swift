//
//  RestorationTokenPlugin.swift
//  APIClient
//
//  Created by Vodolazkyi Anton on 9/24/18.
//

import Foundation

/// The request in use with `RestorationTokenPlugin`
public protocol CredentialProvidableRequest {
    
    /// If true provides request with credentials from `RestorationTokenPlugin`
    var authorizationRequired: Bool { get }
}

extension CredentialProvidableRequest {
    public var authorizationRequired: Bool { return true }
}


public protocol Auth {
    var accessToken: String { get set }
    var exchangeToken: String { get set }
}

/// The plugin to restore the token can be used as the requestor's credential provider
public class RestorationTokenPlugin: PluginType {
    
    /// Callback to send a restore request
    public var onRequest: ((@escaping (Result<Auth>) -> Void) -> Void)?

    private let credentialProvider: AccessCredentialsProvider
    
    /// Auth type to use in header
    private let authType: AuthType

    public init(credentialProvider: AccessCredentialsProvider, authType: AuthType = .default) {
        self.credentialProvider = credentialProvider
        self.authType = authType
    }

    public func prepare(_ request: APIRequest) -> APIRequest {
        var requestProxy = APIRequestProxy(request: request)

        if let request = request as? CredentialProvidableRequest {
            applyHeaders(&requestProxy, applyAuthorization: request.authorizationRequired)
        }

        return requestProxy
    }

    public func canResolve(_ error: Error) -> Bool {
        if (error as? AlamofireExecutorError) == .unauthorized {
            return true
        }
        return false
    }

    public func resolve(_ error: Error, onResolved: @escaping (Bool) -> Void) {
        guard (error as? AlamofireExecutorError) == .unauthorized else {
            onResolved(false)
            return
        }

        guard credentialProvider.exchangeToken != nil else {
            credentialProvider.invalidate()
            onResolved(false)
            return
        }

        onRequest?() { [weak self] result in
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

    // MARK: - Private Methods

    private func applyHeaders(_ request: inout APIRequestProxy, applyAuthorization: Bool) {
        var headers = request.headers ?? [:]

        if let authToken = credentialProvider.accessToken, applyAuthorization {
            var prefix = ""

            if let authPrefix = authType.valuePrefix {
                prefix = authPrefix + " "
            }
            headers[authType.key] = prefix + authToken
        }

        request.headers = headers
    }
    
}
