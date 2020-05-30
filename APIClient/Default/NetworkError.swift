import Foundation

public enum NetworkError: Error {
    
    // general unsatisfied header (e,g, not in range 100...299)
    case unsatisfiedHeader(code: Int)
    // request cancelled
    case canceled
    // bad internet connection, request timed out
    case connection
    // performing authorized action without proper authorization (401)
    case unauthorized
    // internal server error (500)
    case internalServer
    
    // failed to encode params, url or multipart data
    case encoding(Error)
    // failed to parse or deserialize response
    case parsing(Error)
    // user defined error provided in plugin
    case userDefined(Error)
    
    case undefined
}

extension NetworkError {
    
    static func map(_ error: Error) -> NetworkError {
        if let networkError = error as? NetworkError {
            return networkError
        }
        
        return NetworkError.userDefined(error)
    }
    
    static func define(_ error: Error) -> NetworkError? {
        return define((error as NSError).code)
    }
    
    static func define(_ code: Int) -> NetworkError? {
        switch code {
        case NSURLErrorCancelled:
            return NetworkError.canceled
            
        case NSURLErrorNotConnectedToInternet, NSURLErrorTimedOut:
            return NetworkError.connection
            
        case 401:
            return NetworkError.unauthorized
            
        case 500:
            return NetworkError.internalServer
            
        default:
            return nil
        }
    }
}
