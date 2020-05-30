import Foundation

public typealias Response<T> = Result<T, NetworkClientError>

public protocol NetworkClient {
    
    @discardableResult
    func execute<T>(
        request: APIRequest,
        parser: T,
        completion: @escaping (Response<T.Representation>) -> Void
    ) -> Cancelable where T : ResponseParser
    
    @discardableResult
    func execute<T>(
        request: MultipartAPIRequest,
        parser: T,
        completion: @escaping (Response<T.Representation>) -> Void
    ) -> Cancelable where T: ResponseParser
    
    /// Executes download request with progress handled by `downloadRequest.progressHandler`
    ///
    /// - Parameters:
    ///   - request: the request itself
    ///   - destinationFilePath: path to the where data will be saved; default is `nil`
    ///   - parser: parser for response
    ///   - completion: result with response object on success or appropriate error on failure
    /// - Returns: cancelation token
    @discardableResult
    func execute<T>(
        request: DownloadAPIRequest,
        destinationFilePath: URL?,
        parser: T,
        completion: @escaping (Response<T.Representation>) -> Void
    ) -> Cancelable where T: ResponseParser
}
