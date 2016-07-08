import Foundation

public protocol Deserializer {
    
     func deserialize(response: NSHTTPURLResponse, data: NSData) throws -> AnyObject
    
}

public class JSONDeserializer: Deserializer {
    
    public func deserialize(response: NSHTTPURLResponse, data: NSData) throws -> AnyObject {
        do {
            return try NSJSONSerialization
                .JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))
        } catch {
            throw APIError.ResourceDeserialization
        }
    }
    
}
