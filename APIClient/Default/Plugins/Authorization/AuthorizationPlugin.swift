//
//  AuthorizationPlugin.swift
//  APIClient
//
//  Created by Roman Kyrylenko on 10/16/18.
//

/// This plugin provides support for requests' authorization through http headers. Works with `AuthorizableRequest`s only.
public final class AuthorizationPlugin: PluginType {
    
    /// The timespan used to cancel any executing request in case it previously failed authorization
    public static var requestsCancellingTimespan: TimeInterval = 1.0
    
    private let provider: AuthorizationCredentialsProvider
    
    let shouldCancelRequestIfFailed: Bool
    
    weak var delegate: AuthorizationPluginDelegate?
    
    /// - Parameters:
    ///   - provider: An auth data provider used in order to authorize your requests
    ///   - shouldCancelRequestIfFailed: indicates whether APIClient should cancel request if authorization failed previously and it cannot restore it
    public init(provider: AuthorizationCredentialsProvider, shouldCancelRequestIfFailed: Bool = true) {
        self.provider = provider
        self.shouldCancelRequestIfFailed = shouldCancelRequestIfFailed
    }
    
    public func canResolve(_ error: Error) -> Bool {
        if let error = error as? NetworkError, case .unauthorized = error {
            delegate?.reachAuthorizationError()
            return false
        }
        return false
    }
    
    public func prepare(_ request: APIRequest) -> APIRequest {
        guard let authorizableRequest = request as? AuthorizableRequest, authorizableRequest.authorizationRequired else {
            return request
        }
        
        var headers = request.headers ?? [:]
        var prefix = ""
        if let authPrefix = provider.authorizationType.valuePrefix, !authPrefix.isEmpty {
            prefix = authPrefix + " "
        }
        headers[provider.authorizationType.key] = prefix + provider.authorizationToken
        
        return APIRequestProxy(request: request, headers: headers)
    }
}

protocol AuthorizationPluginDelegate: class {
    
    func reachAuthorizationError()
}
