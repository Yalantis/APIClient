import Foundation

public protocol NetworkClient {
    
    @discardableResult
    func execute<T>(request: T, completion: @escaping (Result<T.Parser.Representation>) -> Void) -> Cancelable where T : SerializeableAPIRequest
    
    @discardableResult
    func execute<T, U: ResponseParser>(request: APIRequest, parser: U, completion: @escaping (Result<T>) -> Void) -> Cancelable where U.Representation == T
    
    @discardableResult
    func execute<T, U: ResponseParser>(multipartRequest: APIRequest, parser: U, completion: @escaping (Result<T>) -> Void) -> Cancelable where U.Representation == T
    
    @discardableResult
    func execute<T: SerializeableAPIRequest>(multipartRequest: T, completion: @escaping (Result<T.Parser.Representation>) -> Void) -> Cancelable
    
    /// Executes download request with progress handled by `downloadRequest.progressHandler`
    ///
    /// - Parameters:
    ///   - downloadRequest: the request itself
    ///   - destinationFilePath: path to the where data will be saved; default is `nil`
    ///   - deserializer: deserializer for given request's response
    ///   - parser: parser for response; by default parser from request used
    /// - Returns: task with response object on success or appropriate error on failure
    @discardableResult
    func execute<T, U: ResponseParser>(downloadRequest: APIRequest, destinationFilePath: URL?, deserializer: Deserializer?, parser: U, completion: @escaping (Result<T>) -> Void) -> Cancelable where U.Representation == T
    
}

public extension NetworkClient {
    
    @discardableResult
    public func execute<T>(request: T, completion: @escaping (Result<T.Parser.Representation>) -> Void) -> Cancelable where T : SerializeableAPIRequest {
        return execute(request: request, parser: request.parser, completion: completion)
    }
    
    @discardableResult
    public func execute<T: SerializeableAPIRequest>(multipartRequest: T, completion: @escaping (Result<T.Parser.Representation>) -> Void) -> Cancelable {
        return execute(multipartRequest: multipartRequest, parser: multipartRequest.parser, completion: completion)
    }
    
    @discardableResult
    public func execute<T, U: ResponseParser>(downloadRequest: APIRequest, destinationFilePath: URL?, deserializer: Deserializer?, parser: U, completion: @escaping (Result<T>) -> Void) -> Cancelable where U.Representation == T {
        return execute(
            downloadRequest: downloadRequest,
            destinationFilePath: destinationFilePath,
            deserializer: deserializer,
            parser: parser,
            completion: completion
        )
    }
    
}
