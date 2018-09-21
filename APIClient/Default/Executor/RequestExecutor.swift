import Foundation

public typealias APIResultResponse = (Result<APIClient.HTTPResponse>) -> Void

public protocol RequestExecutor {
    
    func execute(request: APIRequest, completion: @escaping APIResultResponse) -> Cancelable
    func execute(downloadRequest: APIRequest, destinationPath: URL?, completion: @escaping APIResultResponse) -> Cancelable
    func execute(multipartRequest: APIRequest, completion: @escaping APIResultResponse) -> Cancelable
    
}
