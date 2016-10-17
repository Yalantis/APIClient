import Foundation
import Alamofire
import BoltsSwift

class AlamofireRequestExecutor: RequestExecutor {
    
    let manager: SessionManager
    let baseURL: URL
    
    init(baseURL: URL, manager: SessionManager = SessionManager.default) {
        self.manager = manager
        self.baseURL = baseURL
    }
    
    func execute(request: APIRequest) -> Task<APIClient.HTTPResponse> {
        let source = TaskCompletionSource<APIClient.HTTPResponse>()
        
        let requestPath =  baseURL
            .appendingPathComponent(request.path)
            .absoluteString
            .removingPercentEncoding!
        
        manager.request(
            requestPath,
            method: request.alamofireMethod,
            parameters: request.parameters,
            encoding: JSONEncoding(),
            headers: request.headers
        ).response { response in
            guard let httpResponse = response.response, let data = response.data else {
                source.set(error: NetworkError(code: .resourceInvalidResponse))
                
                return
            }
            
            source.set(result: (httpResponse, data))
        }
        
        return source.task
    }
    
    func execute(multipartRequest: APIRequest) -> Task<APIClient.HTTPResponse> {
        guard let multipartFormData = multipartRequest.multipartFormData else {
            fatalError("Missing multipart form data")
        }
        
        let source = TaskCompletionSource<APIClient.HTTPResponse>()
        
        let requestPath = baseURL
            .appendingPathComponent(multipartRequest.path)
            .absoluteString
            .removingPercentEncoding!
        
        manager.upload(
            multipartFormData: multipartFormData,
            to: requestPath,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let request, _, _):
                    request.responseJSON(
                        completionHandler: { response in
                            guard let httpResponse = response.response, let data = response.data else {
                                source.set(error: NetworkError(code: .resourceInvalidResponse))
                                
                                return
                            }
                            
                            source.set(result: (httpResponse, data))
                        }
                    )
                case .failure: source.set(error: NetworkError(code: .resourceInvalidResponse))
                }
            }
        )
        
        return source.task
    }
    
}

extension Alamofire.MultipartFormData: MultipartFormDataType {}
