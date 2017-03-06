//
//  APIRequestProxy.swift
//
//  Created by Roman Kyrylenko on 3/6/17.
//
//

public struct APIRequestProxy: APIRequest {
    
    var path: String
    var method: APIRequestMethod
    var encoding: APIRequestEncoding?
    var parameters: [String: Any]?
    var scopes: [String]?
    var headers: [String: String]?
    var multipartFormData: ((MultipartFormDataType) -> Void)?
    var progressHandler: ProgressHandler?
    
    init(request: APIRequest) {
        path = request.path
        method = request.method
        encoding = request.encoding
        parameters = request.parameters
        scopes = request.scopes
        headers = request.headers
        multipartFormData = request.multipartFormData
        progressHandler = request.progressHandler
    }
    
}
