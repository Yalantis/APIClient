import Foundation

public protocol ResponseParser {
    
    associatedtype Representation
    
    func parse(_ object: AnyObject) throws -> Representation
    
}

public struct EmptyParser: ResponseParser {
    
    public func parse(_ object: AnyObject) throws -> Bool {
        return true
    }
    
}

public struct JSONParser: ResponseParser {
    
    public func parse(_ object: AnyObject) throws -> [String: AnyObject] {
        return object as! [String: AnyObject]
    }
    
}
