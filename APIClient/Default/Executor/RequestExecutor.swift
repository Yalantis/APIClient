import Foundation

public typealias APIResultResponse = (Result<APIClient.HTTPResponse, Error>) -> Void

public protocol RequestExecutor {
    
    func execute(request: APIRequest, completion: @escaping APIResultResponse) -> Cancelable
    func execute(multipartRequest: MultipartAPIRequest, completion: @escaping APIResultResponse) -> Cancelable
    func execute(downloadRequest: DownloadAPIRequest, destinationPath: URL?, completion: @escaping APIResultResponse) -> Cancelable
    
}
