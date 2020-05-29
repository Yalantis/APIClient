import Foundation

public enum NetworkError: Error {
    
    case response(responseDictionary: [String: Any], statusCode: Int)
    case undefined
    case unsatisfiedHeader(code: Int)
    case canceled
    case connection
    case unauthorized
    case internalServer
    case deserialization(Error)
    case encoding(Error)
    case response(Error)
    case parsing(Error)
    case resultValidation(Error)
    case userDefined(Error)
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
