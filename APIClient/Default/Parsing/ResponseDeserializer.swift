import Foundation

public protocol Deserializer {
    
    func deserialize(_ response: HTTPURLResponse, data: Data) -> Result<AnyObject, NetworkClientError.SerializationError>
}
