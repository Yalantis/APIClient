import Foundation
import Alamofire

open class AlamofireRequestExecutor: RequestExecutor {
    
    private let manager: SessionManager
    private let baseURL: URL
    
    public init(baseURL: URL, manager: SessionManager = SessionManager.default) {
        self.manager = manager
        self.baseURL = baseURL
    }
    
    public func execute(request: APIRequest, completion: @escaping APIResultResponse) -> Cancelable {
        let cancellationSource = CancellationTokenSource()
        let requestPath = path(for: request)
        let request = manager
            .request(
                requestPath,
                method: request.alamofireMethod,
                parameters: request.parameters,
                encoding: request.alamofireEncoding,
                headers: request.headers    
            )
            .response { response in
                guard let httpResponse = response.response, let data = response.data else {
                    let networkError: NetworkError
                    if let error = response.error, let definedError = NetworkError.define(error) {
                        networkError = definedError
                    } else if let code = response.response?.statusCode, let definedError = NetworkError.define(code) {
                        networkError = definedError
                    } else {
                        networkError = .undefined
                    }
                    
                    completion(.failure(networkError))
                    
                    return
                }
                completion(.success((httpResponse, data)))
        }
        
        cancellationSource.token.register {
            request.cancel()
        }
        
        return cancellationSource
    }
    
    public func execute(multipartRequest: MultipartAPIRequest, completion: @escaping APIResultResponse) -> Cancelable {
        let cancellationSource = CancellationTokenSource()
        let requestPath = path(for: multipartRequest)
        
        manager
            .upload(
                multipartFormData: multipartRequest.multipartFormData,
                to: requestPath,
                method: multipartRequest.alamofireMethod,
                headers: multipartRequest.headers,
                encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .success(var request, _, _):
                        cancellationSource.token.register {
                            request.cancel()
                        }
                        
                        if let progressHandler = multipartRequest.progressHandler {
                            request = request.uploadProgress { progress in
                                progressHandler(progress)
                            }
                        }
                        request.responseJSON(completionHandler: { response in
                            guard let httpResponse = response.response, let data = response.data else {
                                let networkError: NetworkError
                                if let error = response.error, let definedError = NetworkError.define(error) {
                                    networkError = definedError
                                } else if let code = response.response?.statusCode, let definedError = NetworkError.define(code) {
                                    networkError = definedError
                                } else if let error = response.result.error, let definedError = NetworkError.define(error) {
                                    networkError = definedError
                                } else {
                                    networkError = .undefined
                                }
                                
                                completion(.failure(networkError))
                                
                                return
                            }
                            
                            completion(.success((httpResponse, data)))
                        })
                        
                    case .failure(let error):
                        completion(.failure(NetworkError.encoding(error)))
                    }
            })
        
        return cancellationSource
    }
    
    public func execute(downloadRequest: DownloadAPIRequest, destinationPath: URL?, completion: @escaping APIResultResponse) -> Cancelable {
        let cancellationSource = CancellationTokenSource()
        let requestPath = path(for: downloadRequest)
        
        var request = manager.download(
            requestPath,
            method: downloadRequest.alamofireMethod,
            parameters: downloadRequest.parameters,
            encoding: downloadRequest.alamofireEncoding,
            headers: downloadRequest.headers,
            to: destination(for: destinationPath)
        )
        
        if let progressHandler = downloadRequest.progressHandler {
            request = request.downloadProgress { progress in
                progressHandler(progress)
            }
        }
        
        request.responseData { response in
            guard let httpResponse = response.response, let data = response.result.value else {
                let networkError: NetworkError
                if let error = response.error, let definedError = NetworkError.define(error) {
                    networkError = definedError
                } else if let code = response.response?.statusCode, let definedError = NetworkError.define(code) {
                    networkError = definedError
                } else if let error = response.result.error, let definedError = NetworkError.define(error) {
                    networkError = definedError
                } else {
                    networkError = .undefined
                }
                
                completion(.failure(networkError))
                
                return

            }
            
            completion(.success((httpResponse, data)))
        }
        
        cancellationSource.token.register {
            request.cancel()
        }
        
        return cancellationSource
    }
    
    private func path(for request: APIRequest) -> String {
        return baseURL
            .appendingPathComponent(request.path)
            .absoluteString
            .removingPercentEncoding!
    }
    
    private func destination(for url: URL?) -> DownloadRequest.DownloadFileDestination? {
        guard let url = url else {
            return nil
        }
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            return (url, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        return destination
    }
}

extension Alamofire.MultipartFormData: MultipartFormDataType {}
