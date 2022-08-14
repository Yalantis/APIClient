import Foundation

public protocol ResponseParser {
    
    associatedtype Representation
    
    func parse(_ object: AnyObject) -> Swift.Result<Representation, Error>
}

public struct EmptyParser: ResponseParser {
    
    public init() {}
    
    public func parse(_ object: AnyObject) -> Swift.Result<Bool, Error> {
        return .success(true)
    }
}

public struct JSONParser: ResponseParser {

    public init() {}
    
    public func parse(_ object: AnyObject) -> Swift.Result<[String: AnyObject], Error> {
        return .success(object as! [String: AnyObject])
    }
}
