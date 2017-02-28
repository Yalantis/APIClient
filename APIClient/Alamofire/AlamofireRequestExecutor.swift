import Foundation
import Alamofire
import BoltsSwift

public struct AlamofireExecutorError: Error {
    
    var error: Error?
    
}

open class AlamofireRequestExecutor: RequestExecutor {
    
    open let manager: SessionManager
    open let baseURL: URL
    
    public init(baseURL: URL, manager: SessionManager = SessionManager.default) {
        self.manager = manager
        self.baseURL = baseURL
    }
    
    public func execute(request: APIRequest) -> Task<APIClient.HTTPResponse> {
        let source = TaskCompletionSource<APIClient.HTTPResponse>()
        
        let requestPath =  baseURL
            .appendingPathComponent(request.path)
            .absoluteString
            .removingPercentEncoding!
        
        manager
            .request(
                requestPath,
                method: request.alamofireMethod,
                parameters: request.parameters,
                encoding: JSONEncoding(),
                headers: request.headers
            )
            .response { response in
                guard let httpResponse = response.response, let data = response.data else {
                    source.set(error: AlamofireExecutorError(error: response.error))
                    
                    return
                }
                
                source.set(result: (httpResponse, data))
        }
        
        return source.task
    }
    
    public func execute(download request: APIRequest) -> Task<APIClient.HTTPResponse> {
        let source = TaskCompletionSource<APIClient.HTTPResponse>()
        
        let requestPath =  baseURL
            .appendingPathComponent(request.path)
            .absoluteString
            .removingPercentEncoding!
        
        var downloadRequest = manager.download(
            requestPath,
            method: request.alamofireMethod,
            parameters: request.parameters,
            encoding: JSONEncoding(),
            headers: request.headers)
        if let progressHandler = request.progressHandler {
            downloadRequest = downloadRequest.downloadProgress { progress in
                progressHandler(progress)
            }
        }
        
        downloadRequest.responseData { response in
            guard let httpResponse = response.response, let data = response.result.value else {
                source.set(error: AlamofireExecutorError(error: response.error ?? response.result.error))
                
                return
            }
            
            source.set(result: (httpResponse, data))
        }
        
        return source.task
    }
    
    public func execute(multipartRequest: APIRequest) -> Task<APIClient.HTTPResponse> {
        guard let multipartFormData = multipartRequest.multipartFormData else {
            fatalError("Missing multipart form data")
        }
        
        let source = TaskCompletionSource<APIClient.HTTPResponse>()
        
        let requestPath = baseURL
            .appendingPathComponent(multipartRequest.path)
            .absoluteString
            .removingPercentEncoding!
        
        manager
            .upload(
                multipartFormData: multipartFormData,
                to: requestPath,
                method: multipartRequest.alamofireMethod,
                headers: multipartRequest.headers,
                encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .success(var request, _, _):
                        if let progressHandler = multipartRequest.progressHandler {
                            request = request.uploadProgress { progress in
                                progressHandler(progress)
                            }
                        }
                        request.responseJSON(completionHandler: { response in
                            guard let httpResponse = response.response, let data = response.data else {
                                source.set(error: AlamofireExecutorError(error: response.error))
                                
                                return
                            }
                            
                            source.set(result: (httpResponse, data))
                        })
                        
                    case .failure(let error):
                        source.set(error: AlamofireExecutorError(error: error))
                        
                    }
            }
        )
        
        return source.task
    }
    
}

extension Alamofire.MultipartFormData: MultipartFormDataType {}
