//
//  AuthorizationPlugin.swift
//  APIClient
//
//  Created by Roman Kyrylenko on 10/16/18.
//

/// Adopt this protocol in order to be able to authorize your request
public protocol AuthorizableRequest {
    
    /// If true provides request with credentials from `RestorationTokenPlugin`
    var authorizationRequired: Bool { get }
}

extension AuthorizableRequest {
    
    public var authorizationRequired: Bool { return true }
}

/// This plugin provides support for requests' authorization through http headers
public final class AuthorizationPlugin: PluginType {
    
    private let provider: AuthorizationCredentialsProvider
    
    /// - Parameter provider: An auth data provider used in order to authorize your requests
    public init(provider: AuthorizationCredentialsProvider) {
        self.provider = provider
    }
    
    public func prepare(_ request: APIRequest) -> APIRequest {
        guard let authorizableRequest = request as? AuthorizableRequest, authorizableRequest.authorizationRequired else {
            return request
        }
        
        var headers = request.headers ?? [:]
        var prefix = ""
        if let authPrefix = provider.authorizationType.valuePrefix {
            prefix = authPrefix + " "
        }
        headers[provider.authorizationType.key] = prefix + provider.authorizationToken
        
        return APIRequestProxy(request: request, headers: headers)
    }
}
