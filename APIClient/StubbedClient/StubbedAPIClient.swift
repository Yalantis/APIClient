//
//  StubbedAPIClient.swift
//  APIClient
//
//  Created by Roman Kyrylenko on 2/28/17.
//  Copyright © 2017 Eugene Andreyev. All rights reserved.
//

import BoltsSwift

open class StubbedAPIClient: NetworkClient {
    
    let responseDelay: TimeInterval = 0.7
    
    public func execute<T, U: ResponseParser>(request: APIRequest, parser: U) -> Task<T> where U.Representation == T {
        return Task<T>(error: NSError())
    }
    
    public func execute<T : SerializeableAPIRequest>(request: T) -> Task<T.Parser.Representation> {
        return Task<T.Parser.Representation>(error: NSError())
    }
    
    public func execute<T, U: ResponseParser>(multipartRequest: APIRequest, parser: U) -> Task<T> where U.Representation == T {
        return Task<T>(error: NSError())
    }
    
    public func execute<T : SerializeableAPIRequest>(multipartRequest: T) -> Task<T.Parser.Representation> {
        return Task<T.Parser.Representation>(error: NSError())
    }
    
    public func execute<T, U: ResponseParser>(downloadRequest: APIRequest, parser: U) -> Task<T> where U.Representation == T {
        return Task<T>(error: NSError())
    }
    
    public func execute<T : SerializeableAPIRequest>(downloadRequest: T) -> Task<T.Parser.Representation> {
        return Task<T.Parser.Representation>(error: NSError())
    }
    
}
