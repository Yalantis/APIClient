import Foundation

public class JSONDeserializer: Deserializer {
    
    public func deserialize(_ response: HTTPURLResponse, data: Data) -> Result<AnyObject, Error> {
        do {
            let jsonObject = try JSONSerialization
                .jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject
            return .success(jsonObject)
        } catch let error {
            if (error as NSError).code == 3840 { // empty response
                return .success(NSArray())
            }
            return .failure(error)
        }
    }
    
    public init() {}
}
