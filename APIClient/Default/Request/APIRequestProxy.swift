//
//  APIRequestProxy.swift
//
//  Created by Roman Kyrylenko on 3/6/17.
//
//

public class APIRequestProxy: APIRequest {

    public var path: String
    public var method: APIRequestMethod
    public var encoding: APIRequestEncoding?
    public var parameters: [String: Any]?
    public var headers: [String: String]?
    public var multipartFormData: ((MultipartFormDataType) -> Void)?
    public var progressHandler: ProgressHandler?

    public init(request: APIRequest) {
        path = request.path
        method = request.method
        encoding = request.encoding
        parameters = request.parameters
        headers = request.headers
        
        if let multipartRequest = request as? MultipartAPIRequest {
            multipartFormData = multipartRequest.multipartFormData
            progressHandler = multipartRequest.progressHandler
        } else if let downloadRequest = request as? DownloadAPIRequest {
            progressHandler = downloadRequest.progressHandler
        }
    }

}
