import Foundation
import BoltsSwift

public protocol NetworkClient {
    
    func execute<T, U: ResponseParser>(request: APIRequest, parser: U) -> Task<T> where U.Representation == T
    
    func execute<T : SerializeableAPIRequest>(request: T) -> Task<T.Parser.Representation>
    
    func execute<T, U: ResponseParser>(multipartRequest: APIRequest, parser: U) -> Task<T> where U.Representation == T
    
    func execute<T : SerializeableAPIRequest>(multipartRequest: T) -> Task<T.Parser.Representation>
    
    func execute<T, U: ResponseParser>(downloadRequest: APIRequest, destinationPath: URL?,  parser: U) -> Task<T> where U.Representation == T
    
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
    
    func execute<T : SerializeableAPIRequest>(downloadRequest: T, destinationPath: URL?) -> Task<T.Parser.Representation> {
        return execute(downloadRequest: downloadRequest, destinationPath: destinationPath, parser: downloadRequest.parser)
    }
    
}
