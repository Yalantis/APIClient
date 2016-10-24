import Foundation

public struct NetworkError: Error, Hashable, Equatable {
    
    let rawResponseDictionary: [String: Any]?
    let statusCode: Int
    
    // MARK: Lifecycle
    
    public init(statusCode: Int, rawResponseDictionary: [String: Any]? = nil) {
        self.statusCode = statusCode
        self.rawResponseDictionary = rawResponseDictionary
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
