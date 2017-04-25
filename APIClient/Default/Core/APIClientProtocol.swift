import Foundation
import BoltsSwift

public protocol NetworkClient {
    
    func execute<T, U: ResponseParser>(request: APIRequest, parser: U) -> Task<T> where U.Representation == T
    
    func execute<T : SerializeableAPIRequest>(request: T) -> Task<T.Parser.Representation>
    
    func execute<T, U: ResponseParser>(multipartRequest: APIRequest, parser: U) -> Task<T> where U.Representation == T
    
    func execute<T : SerializeableAPIRequest>(multipartRequest: T) -> Task<T.Parser.Representation>
    
    /// Executes download request with progress handled by `downloadRequest.progressHandler`
    ///
    /// - Parameters:
    ///   - downloadRequest: the request itself
    ///   - destinationFilePath: path to the where data will be saved; default is `nil`
    ///   - deserializer: deserializer for given request's response
    ///   - parser: parser for response; by default parser from request used
    /// - Returns: task with response object on success or appropriate error on failure
    func execute<T, U: ResponseParser>(downloadRequest: APIRequest, destinationFilePath: URL?, deserializer: Deserializer?,  parser: U) -> Task<T> where U.Representation == T
    
}

public extension NetworkClient {
    
    func execute<T, U: ResponseParser>(request: APIRequest, parser: U) -> Task<T> where U.Representation == T {
        return Task<T>(error: NSError())
    }
    
    func execute<T, U: ResponseParser>(multipartRequest: APIRequest, parser: U) -> Task<T> where U.Representation == T {
        return Task<T>(error: NSError())
    }
    
    func execute<T, U: ResponseParser>(downloadRequest: APIRequest, parser: U) -> Task<T> where U.Representation == T {
        return Task<T>(error: NSError())
    }
    
    func execute<T : SerializeableAPIRequest>(request: T) -> Task<T.Parser.Representation> {
        return execute(request: request, parser: request.parser)
    }
    
    func execute<T : SerializeableAPIRequest>(multipartRequest: T) -> Task<T.Parser.Representation> {
        return execute(multipartRequest: multipartRequest, parser: multipartRequest.parser)
    }
    
    func execute<T : SerializeableAPIRequest>(downloadRequest: T, destinationFilePath: URL? = nil, deserializer: Deserializer?) -> Task<T.Parser.Representation> {
        return execute(
            downloadRequest: downloadRequest,
            destinationFilePath: destinationFilePath,
            deserializer: deserializer,
            parser: downloadRequest.parser
        )
    }
    
}
