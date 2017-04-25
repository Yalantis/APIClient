//
//  APIRequestProxy.swift
//
//  Created by Roman Kyrylenko on 3/6/17.
//
//

public struct APIRequestProxy: APIRequest {
    
    public var path: String
    public var method: APIRequestMethod
    public var encoding: APIRequestEncoding?
    public var parameters: [String: Any]?
    public var scopes: [String]?
    public var headers: [String: String]?
    public var multipartFormData: ((MultipartFormDataType) -> Void)?
    public var progressHandler: ProgressHandler?
    
    public init(request: APIRequest) {
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
