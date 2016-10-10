//
//  APIClientProtocol.swift
//  CuratumPlatform
//
//  Created by Eugene Andreyev on 7/25/16.
//  Copyright © 2016 Eugene Andreyev. All rights reserved.
//

import Foundation
import BoltsSwift

public protocol NetworkClient {
    
    func execute<T, U: ResponseParser>(request: APIRequest, parser: U) -> Task<T> where U.Representation == T
    
    func execute<T : SerializeableAPIRequest>(request: T) -> Task<T.Parser.Representation>
    
    func execute<T, U: ResponseParser>(multipartRequest: APIRequest, parser: U) -> Task<T> where U.Representation == T
    
    func execute<T : SerializeableAPIRequest>(multipartRequest: T) -> Task<T.Parser.Representation>
    
}

extension NetworkClient {
    
    
    func execute<T, U: ResponseParser>(request: APIRequest, parser: U) -> Task<T> where U.Representation == T {
        return Task<T>(error: NSError())
    }
    
    func execute<T : SerializeableAPIRequest>(request: T) -> Task<T.Parser.Representation> {
        return Task<T.Parser.Representation>(error: NSError())
    }
    
    func execute<T, U: ResponseParser>(multipartRequest: APIRequest, parser: U) -> Task<T> where U.Representation == T {
        return Task<T>(error: NSError())
    }
    
    func execute<T : SerializeableAPIRequest>(multipartRequest: T) -> Task<T.Parser.Representation> {
        return Task<T.Parser.Representation>(error: NSError())
    }
    
}
