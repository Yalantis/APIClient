import Foundation

public protocol Deserializer {
    
     func deserialize(response: NSHTTPURLResponse, data: NSData) throws -> AnyObject
    
}
