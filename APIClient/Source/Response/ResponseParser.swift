import Foundation
import ObjectMapper

public protocol ResponseParser {
    
    associatedtype Representation
    
    func parse(_ object: AnyObject) throws -> Representation
    
}

struct EmptyParser: ResponseParser {
    
    func parse(_ object: AnyObject) throws -> Bool {
        return true
    }
    
}

struct JSONParser: ResponseParser {
    
    func parse(_ object: AnyObject) throws -> [String: AnyObject] {
        return object as! [String: AnyObject]
    }
    
}
