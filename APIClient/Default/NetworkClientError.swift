import Foundation

public enum NetworkClientError: Error {

    public enum NetworkError: Error {
        
        // general unsatisfied header (e,g, not in range 200..<300)
        case unsatisfiedHeader(code: Int)
        // request cancelled
        case canceled
        // bad internet connection, request timed out
        case connection
        // performing authorized action without proper authorization (401)
        case unauthorized
        // internal server error (500)
        case internalServer
    }
    
    public enum SerializationError: Error {
        
        // failed to encode params, url or multipart data
        case encoding(Error)
        // failed to parse or deserialize response
        case parsing(Error)
    }
    
    case network(NetworkError)
    case serialization(SerializationError)
    
    // user defined error provided in plugin
    case userDefined(Error)
    // error from request executor (e.g. AFError in case of AFExecutor)
    case executor(Error)
    
    case undefined(Error?)
}

extension NetworkClientError {
    
    public var underlyingError: Error? {
        switch self {
        case .executor(let error): return error
        case .network(let error): return error
        case .userDefined(let error): return error
        case .undefined(let error): return error
        case .serialization(let error): return error
        }
    }
    
    static func compactMap(_ error: Error) -> NetworkClientError {
        if let networkError = error as? NetworkClientError {
            return networkError
        }
        
        return NetworkClientError.userDefined(error)
    }
    
    static func define(_ error: Error) -> NetworkClientError? {
        return define((error as NSError).code)
    }
    
    static func define(_ code: Int) -> NetworkClientError? {
        switch code {
        case NSURLErrorCancelled:
            return NetworkClientError.network(NetworkError.canceled)
            
        case NSURLErrorNotConnectedToInternet, NSURLErrorTimedOut:
            return NetworkClientError.network(NetworkError.connection)
            
        case 401:
            return NetworkClientError.network(NetworkError.unauthorized)
            
        case 500:
            return NetworkClientError.network(NetworkError.internalServer)
            
        default:
            return nil
        }
    }
}
