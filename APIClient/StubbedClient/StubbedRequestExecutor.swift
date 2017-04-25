//
//  StubbedAPIClient.swift
//  APIClient
//
//  Created by Roman Kyrylenko on 2/28/17.
//  Copyright © 2017 Eugene Andreyev. All rights reserved.
//

import BoltsSwift
import OHHTTPStubs
import Alamofire

open class StubbedRequestExecutor: AlamofireRequestExecutor {
    
    private var requestTime: TimeInterval
    
    public init(baseURL: URL, manager: SessionManager = SessionManager.default, requestTime: TimeInterval = 0.0) {
        self.requestTime = requestTime

        super.init(baseURL: baseURL, manager: manager)
    }
    
    public override func execute(request: APIRequest) -> Task<APIClient.HTTPResponse> {
        guard let stubbedRequest = request as? StubbedAPIRequest, let path = stubbedRequest.stubPath else {
            return super.execute(request: request)
        }
        stub(condition: pathStartsWith("/\(request.path)")) { _ in
            return OHHTTPStubsResponse(fileAtPath: path,
                                       statusCode: 200,
                                       headers: [ "Content-Type": "application/json" ]).responseTime(self.requestTime)
            
        }
        
        return super.execute(request: request)
    }

}
