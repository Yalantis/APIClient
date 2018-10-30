//
//  AuthorizationCredentialsProvider.swift
//  APIClient
//
//  Created by Roman Kyrylenko on 10/16/18.
//

import Foundation

public protocol AuthorizationCredentialsProvider: class {
    
    var authorizationToken: String { get }
    var authorizationType: AuthType { get }
}
