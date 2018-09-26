//
//  RequestDecorationPlugin.swift
//  APIClient
//
//  Created by Vodolazkyi Anton on 9/24/18.
//

import Foundation

public protocol DecoratableRequest {
    var authorizationRequired: Bool { get }
}

extension DecoratableRequest {
    public var authorizationRequired: Bool { return true }
}

public protocol Auth {
    var accessToken: String { get set }
    var exchangeToken: String { get set }
}

// TODO: add proper documentation
public class RequestDecorationPlugin: PluginType {
    
    public var onRequest: ((APIRequest, @escaping (Result<Auth>) -> Void) -> Void)?
    
    private let credentialProvider: AccessCredentialsProvider
    private let restoreRequest: APIRequest?
    private let authType: AuthType
    
    public init(credentialProvider: AccessCredentialsProvider, restoreRequest: APIRequest?, authType: AuthType = .default) {
        self.credentialProvider = credentialProvider
        self.restoreRequest = restoreRequest
        self.authType = authType
    }
    
    public func prepare(_ request: APIRequest) -> APIRequest {
        var requestProxy = APIRequestProxy(request: request)
        
        if let request = request as? DecoratableRequest {
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
        
        guard let request = restoreRequest, credentialProvider.exchangeToken != nil else {
            credentialProvider.invalidate()
            onResolved(false)
            return
        }
        
        onRequest?(request) { [weak self] result in
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
