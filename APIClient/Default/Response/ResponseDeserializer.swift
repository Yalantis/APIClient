import Foundation

public protocol Deserializer {
    
    func deserialize(_ response: HTTPURLResponse, data: Data) -> Swift.Result<AnyObject, Error>
    
}
