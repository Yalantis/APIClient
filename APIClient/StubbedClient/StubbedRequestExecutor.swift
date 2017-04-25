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
    
    public override func execute(request: APIRequest) -> Task<APIClient.HTTPResponse> {
        guard let stubbedRequest = request as? StubbedAPIRequest, let requestStub = stubbedRequest.stub else {
            return super.execute(request: request)
        }
        
        stub(condition: pathStartsWith("/\(request.path)")) { _ in
            return requestStub.response()
        }
        
        return super.execute(request: request)
    }
    
}
