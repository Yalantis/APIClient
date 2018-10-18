//
//  AuthorizableRequest.swift
//  APIClient
//
//  Created by Roman Kyrylenko on 10/18/18.
//

/// Adopt this protocol in order to be able to authorize your request
public protocol AuthorizableRequest {
    
    /// If true provides request with credentials from `RestorationTokenPlugin`
    var authorizationRequired: Bool { get }
}

extension AuthorizableRequest {
    
    public var authorizationRequired: Bool { return true }
}
