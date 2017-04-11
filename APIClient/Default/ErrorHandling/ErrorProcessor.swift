import Foundation

public protocol ErrorProcessing {
    
    func processError(using response: APIClient.HTTPResponse) -> Error?
    
}

public struct NetworkErrorProcessor: ErrorProcessing {
    
    private let deserializer = JSONDeserializer()
    
    public func processError(using response: APIClient.HTTPResponse) -> Error? {
        if let dictionary = (try? deserializer.deserialize(response.httpResponse, data: response.data)) as? [String: AnyObject] {
            return NetworkError(statusCode: response.httpResponse.statusCode, responseDictionary: dictionary)
        }
        
        return nil
    }
    
}
