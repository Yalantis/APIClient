//
//  AlamofireRequestExecutor.swift
//  RegistrationAndProfileFlow-Demo
//
//  Created by Eugene Andreyev on 5/13/16.
//  Copyright © 2016 Eugene Andreyev. All rights reserved.
//

import Foundation
import Alamofire
import BoltsSwift
import APIClient

public class AlamofireRequestExecutor: RequestExecutor {
    
    let manager: Manager
    let baseURL: NSURL
    
    public init(baseURL: NSURL, manager: Manager = Manager.sharedInstance) {
        self.manager = manager
        self.baseURL = baseURL
    }
    
    public func executeRequest(request: APIRequest) -> Task<APIClient.HTTPResponse> {
        let source = TaskCompletionSource<APIClient.HTTPResponse>()
        
        let requestPath = baseURL
            .URLByAppendingPathComponent(request.path)
            .absoluteString
            .stringByRemovingPercentEncoding
        
        manager.request(
            request.alamofireMethod,
            requestPath!,
            headers: request.headers,
            parameters: request.parameters
            ).response { _, response, data, error in
                guard let response = response, let data = data else {
                    source.setError(APIError.ResourceInvalidResponse)
                    
                    return
                }
                
                source.setResult((response, data))
        }
        
        return source.task
    }
    
    public func executeMultipartRequest(request: APIRequest) -> Task<APIClient.HTTPResponse> {
        guard let multipartFormData = request.multipartFormData else {
            fatalError("Missing multipart form data")
        }
        
        let source = TaskCompletionSource<APIClient.HTTPResponse>()
        
        let requestPath = baseURL
            .URLByAppendingPathComponent(request.path)
            .absoluteString
            .stringByRemovingPercentEncoding
        
        manager.upload(
            request.alamofireMethod,
            requestPath!,
            headers: request.headers,
            multipartFormData: { formData in
                multipartFormData(formData)
            },
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let request, _, _):
                    request.responseJSON(
                        completionHandler: { response in
                            guard let httpResponse = response.response, let data = response.data else {
                                source.setError(APIError.ResourceInvalidResponse)
                                
                                return
                            }
                           
                            source.setResult((httpResponse, data))
                        }
                    )
                case .Failure: source.setError(APIError.ResourceInvalidResponse)
                }
            }
        )
        
        return source.task
    }
    
}

extension Alamofire.MultipartFormData: MultipartFormDataType {}
