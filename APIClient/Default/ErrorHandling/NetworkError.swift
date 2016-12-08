import Foundation

public struct NetworkError: Error, Hashable, Equatable {
    
    public let responseDictionary: [String: Any]?
    public let statusCode: Int
    
    // MARK: Lifecycle
    
    public init(statusCode: Int, responseDictionary: [String: Any]? = nil) {
        self.statusCode = statusCode
        self.responseDictionary = responseDictionary
    }
    
    // MARK: Equatable
    
    static public func ==(lhs: NetworkError, rhs: NetworkError) -> Bool {
        return lhs.statusCode == rhs.statusCode
    }
    
    // MARK: Hashable
    
    public var hashValue: Int {
        return statusCode.hashValue
    }
    
    // MARK: Defaults
    
    static var undefined: NetworkError {
        return NetworkError(statusCode: -1)
    }
    
}
