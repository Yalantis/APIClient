//
//  APIRequest+Stub.swift
//  APIClient
//
//  Created by Anton Vodolazkyi on 2/28/17.
//  Copyright © 2017 Yalantis. All rights reserved.
//

import Foundation
import OHHTTPStubs

public struct Stub {
    
    var responseTime: TimeInterval
    var code: Int32
    var header: [AnyHashable : Any]
    var content: StubContent
    var error: Error?
    
    public init(content: StubContent, error: Error? = nil, responseTime: TimeInterval = 1.0, header: [AnyHashable : Any] = [ "Content-Type": "application/json" ], code: Int32 = 200) {
        self.content = content
        self.error = error
        self.responseTime = responseTime
        self.header = header
        self.code = code
    }
    
}

extension Stub {
    
    func response() -> OHHTTPStubsResponse {
        if let error = error {
            return OHHTTPStubsResponse(error: error)
        }
        let response: OHHTTPStubsResponse
        
        switch content {
        case let .jsonFile(path):
            response = OHHTTPStubsResponse(
                fileAtPath: path,
                statusCode: code,
                headers: header
            )
        case let .jsonUrl(url):
            response = OHHTTPStubsResponse(
                fileURL: url,
                statusCode: code,
                headers: header
            )
        case let .json(object):
            response = OHHTTPStubsResponse(
                jsonObject: object,
                statusCode: code,
                headers: header
            )
        case let .data(data):
            response = OHHTTPStubsResponse(
                data: data,
                statusCode: code,
                headers: header
            )
        }
        
        return response
            .responseTime(responseTime)
        
    }
    
}
