import Foundation

// TODO: this is useless right now; we need to think how to combine it with AlamofireRequestExecutor's error
// probably we can just rename AlamofireExecutorError -> NetworkError, add `undefined` case and use that single type
public struct NetworkError: Error, Hashable, Equatable {
    
    public let responseDictionary: [String: Any]?
    public let statusCode: Int
    
    // MARK: Lifecycle
    
    public init(statusCode: Int, responseDictionary: [String: Any]? = nil) {
        self.statusCode = statusCode
        self.responseDictionary = responseDictionary
    }
    
    // MARK: Equatable
    
    public static func ==(lhs: NetworkError, rhs: NetworkError) -> Bool {
        return lhs.statusCode == rhs.statusCode
    }
    
    // MARK: Hashable
    
    public var hashValue: Int {
        return statusCode.hashValue
    }
    
    // MARK: Defaults
    
    public static var undefined: NetworkError {
        return NetworkError(statusCode: -1)
    }
    
}
