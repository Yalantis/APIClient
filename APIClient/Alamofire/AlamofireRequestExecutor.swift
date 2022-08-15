import Foundation
import Alamofire

open class AlamofireRequestExecutor: RequestExecutor {
    
    private let manager: Session
    private let baseURL: URL
    
    public init(baseURL: URL, manager: Session = .default) {
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
                headers: request.alamofireHeaders
            )
            .response { response in
                guard let httpResponse = response.response, let data = response.data else {
                    AlamofireRequestExecutor.defineError(response.error, completion: completion)
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
      
      manager.upload(
          multipartFormData: multipartRequest.multipartFormData,
          to: requestPath,
          method: multipartRequest.alamofireMethod,
          headers: multipartRequest.alamofireHeaders)
      .uploadProgress(queue: .main, closure: { progress in
          if let progressHandler = multipartRequest.progressHandler {
              progressHandler(progress)
          }
      })
      .responseJSON { response in
          switch response.result {
          case .success:
            guard
                let httpResponse = response.response,
                let data = response.data
            else {
                AlamofireRequestExecutor.defineError(response.error, completion: completion)
            
                return
            }
          
            completion(.success((httpResponse, data)))

        case .failure(let error):
            completion(.failure(error))
        }
      }
     
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
            headers: downloadRequest.alamofireHeaders,
            to: destination(for: destinationPath)
        )
        
        if let progressHandler = downloadRequest.progressHandler {
            request = request.downloadProgress { progress in
                progressHandler(progress)
            }
        }
        
        request.responseData { response in
            guard
              let httpResponse = response.response,
              let data = response.value
            else {
              AlamofireRequestExecutor.defineError(response.error, completion: completion)
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
    
    private func destination(for url: URL?) -> DownloadRequest.Destination? {
        guard let url = url else {
            return nil
        }
        let destination: DownloadRequest.Destination = { _, _ in
            return (url, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        return destination
    }
    
    private class func defineError(_ error: Error?, completion: @escaping APIResultResponse) {
        guard let error = error else {
            completion(.failure(NetworkError.undefined))
            return
        }
        
        switch (error as NSError).code {
        case NSURLErrorCancelled:
            completion(.failure(NetworkError.canceled))
        case NSURLErrorNotConnectedToInternet, NSURLErrorTimedOut:
            completion(.failure(NetworkError.connection))
        default:
            completion(.failure(error))
        }
    }
    
}

extension Alamofire.MultipartFormData: MultipartFormDataType {}
