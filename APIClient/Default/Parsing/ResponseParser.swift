import Foundation

public protocol ResponseParser {
    
    associatedtype Representation
    
    func parse(_ object: AnyObject) -> Result<Representation, NetworkError>
}

public struct EmptyParser: ResponseParser {
    
    public init() {}
    
    public func parse(_ object: AnyObject) -> Result<Bool, NetworkError> {
        return .success(true)
    }
}

public struct JSONParser: ResponseParser {

    public init() {}
    
    public func parse(_ object: AnyObject) -> Result<[String: AnyObject], NetworkError> {
        return .success(object as! [String: AnyObject])
    }
}
