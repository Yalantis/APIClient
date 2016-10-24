import Foundation

public struct JSONDeserializationError: Error {}

public class JSONDeserializer: Deserializer {
    
    public func deserialize(_ response: HTTPURLResponse, data: Data) throws -> AnyObject {
        do {
            return try JSONSerialization
                .jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject
        } catch {
            throw JSONDeserializationError()
        }
    }
    
}
