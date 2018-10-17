import Foundation

public struct NetworkErrorProcessor: ErrorProcessing {
    
    private let deserializer = JSONDeserializer()
    
    public init() {}
    
    public func processError(using response: APIClient.HTTPResponse) -> Error? {
        if case let .success(result) = deserializer.deserialize(response.httpResponse, data: response.data), let dictionary = result as? [String: Any] {
            return NetworkError.response(responseDictionary: dictionary, statusCode: response.httpResponse.statusCode)
        }
        
        return nil
    }
}
