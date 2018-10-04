import Foundation

public enum NetworkError: Error {
    
    case response(responseDictionary: [String: Any], statusCode: Int)
    case undefined
    case canceled
    case connection
    case unauthorized
    case internalServer
}
