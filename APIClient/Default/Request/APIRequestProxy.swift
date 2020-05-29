//
//  APIRequestProxy.swift
//  APIClient
//
//  Created by Roman Kyrylenko on 3/6/17.
//
//

public class APIRequestProxy: MultipartAPIRequest {
    
    public let origin: APIRequest
    public var path: String
    public var method: APIRequestMethod
    public var encoding: APIRequestEncoding
    public var parameters: [String: Any]?
    public var headers: [String: String]?
    public var multipartFormData: ((MultipartFormDataType) -> Void)
    public var progressHandler: ProgressHandler?
    
    public init(request: APIRequest) {
        if let proxy = request as? APIRequestProxy {
            origin = proxy.origin
        } else {
            origin = request
        }
        path = request.path
        method = request.method
        encoding = request.encoding
        parameters = request.parameters
        headers = request.headers
        multipartFormData = (request as? MultipartAPIRequest)?.multipartFormData ?? { _ in }
        progressHandler = (request as? DownloadAPIRequest)?.progressHandler
    }
}
