import Foundation
import Alamofire

open class AlamofireRequestExecutor: RequestExecutor {
    
    private let baseURL: URL
    
    public init(baseURL: URL) {
        self.baseURL = baseURL
    }
    
    public func execute(request: APIRequest, completion: @escaping APIResultResponse) -> Cancelable {
        let cancellationSource = CancellationTokenSource()
        let requestPath = path(for: request)
        let request = AF.request(
            requestPath,
            method: request.afMethod,
            parameters: request.parameters,
            encoding: request.afEncoding,
            headers: request.afHeaders
        )
        cancellationSource.token.register {
            request.cancel()
        }
        
        request.response { (response: DataResponse<Data?, AFError>) in
            if let httpResponse = response.response, let data = response.data {
                completion(Result.success((httpResponse, data)))
                
                return
            }
            
            completion(Result.failure(
                AlamofireRequestExecutor.defineError(
                    responseError: response.error,
                    responseStatusCode: response.response?.statusCode
                )
            ))
        }
        
        return cancellationSource
    }
    
    public func execute(multipartRequest: MultipartAPIRequest, completion: @escaping APIResultResponse) -> Cancelable {
        let cancellationSource = CancellationTokenSource()
        let requestPath = path(for: multipartRequest)
        
        let request = AF.upload(
            multipartFormData: multipartRequest.multipartFormData,
            to: requestPath,
            method: multipartRequest.afMethod,
            headers: multipartRequest.afHeaders
        )
        cancellationSource.token.register {
            request.cancel()
        }
        if let progressHandler = multipartRequest.progressHandler {
            request.uploadProgress { (progress: Progress) in
                progressHandler(progress)
            }
        }
        
        request.responseJSON { (response: DataResponse<Any, AFError>) in
            if let httpResponse = response.response, let data = response.data {
                completion(Result.success((httpResponse, data)))
                
                return
            }
            
            completion(Result.failure(
                AlamofireRequestExecutor.defineError(
                    responseError: response.error,
                    responseStatusCode: response.response?.statusCode
                )
            ))
        }
        
        return cancellationSource
    }
    
    public func execute(downloadRequest: DownloadAPIRequest, destinationPath: URL?, completion: @escaping APIResultResponse) -> Cancelable {
        let cancellationSource = CancellationTokenSource()
        let requestPath = path(for: downloadRequest)
        
        let request = AF.download(
            requestPath,
            method: downloadRequest.afMethod,
            parameters: downloadRequest.parameters,
            encoding: downloadRequest.afEncoding,
            headers: downloadRequest.afHeaders,
            to: destination(for: destinationPath)
        )
        cancellationSource.token.register {
            request.cancel()
        }
        if let progressHandler = downloadRequest.progressHandler {
            request.downloadProgress { (progress: Progress) in
                progressHandler(progress)
            }
        }
        
        request.responseData { (response: DownloadResponse<Data, AFError>) in
            if let httpResponse = response.response, let data = response.result.value {
                completion(Result.success((httpResponse, data)))
                
                return
            }
            
            completion(Result.failure(
                AlamofireRequestExecutor.defineError(
                    responseError: response.error,
                    responseStatusCode: response.response?.statusCode
                )
            ))
        }
        
        return cancellationSource
    }
    
    private func path(for request: APIRequest) -> String {
        return baseURL
            .appendingPathComponent(request.path)
            .absoluteString
            .removingPercentEncoding!
    }
    
    private func destination(for url: URL?) -> DownloadRequest.Destination? {
        guard let url = url else {
            return nil
        }
        
        let destination: DownloadRequest.Destination = { _, _ -> (URL, DownloadRequest.Options) in
            return (url, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        return destination
    }
    
    private static func defineError(responseError: AFError?, responseStatusCode: Int?) -> NetworkClientError {
        guard let error = responseError else {
            if let code = responseStatusCode, let definedError = NetworkClientError.define(code) {
                return definedError
            }
            
            return NetworkClientError.undefined(responseError)
        }
        
        if let definedError = NetworkClientError.define(error) {
           return definedError
        }
        
        return NetworkClientError.map(error)
    }
}

extension NetworkClientError {
    
    static func map(_ error: AFError) -> NetworkClientError {
        if let code = error.responseCode, let definedError = NetworkClientError.define(code) {
            return definedError
        }
        
        if let underlyingError = error.underlyingError, let definedError = NetworkClientError.define(underlyingError) {
            return definedError
        }
        
        switch error {
        case .explicitlyCancelled: return NetworkClientError.network(.canceled)
        case .responseSerializationFailed: return NetworkClientError.serialization(.parsing(error))
        case .responseValidationFailed(let reason):
            switch reason {
            case .unacceptableStatusCode(let code):
                if let definedError = NetworkClientError.define(code) {
                    return definedError
                }
            default: break
            }
            
        default: break
        }
        
        return NetworkClientError.executor(error)
    }
}

extension Alamofire.MultipartFormData: MultipartFormDataType {
    
    public func append(_ stream: InputStream, withLength length: UInt64, headers: [String : String]) {
        let httpHeaders = HTTPHeaders(headers)
        append(stream, withLength: length, headers: httpHeaders)
    }
}
