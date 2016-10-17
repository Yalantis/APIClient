import Foundation

public protocol APIErrorProcessing {
    
    func processErrorWithResponse(_ response: APIClient.HTTPResponse) -> NetworkError
    
}

public struct APIErrorProcessor: APIErrorProcessing {
    
    private let deserializer = JSONDeserializer()
    
    public func processErrorWithResponse(_ response: APIClient.HTTPResponse) -> NetworkError {
        if let dictionary = (try? deserializer.deserialize(response.0, data: response.1)) as? [String: AnyObject],
           let error = NetworkError(dictionary: dictionary) {
                return error
        }
        
        return NetworkError.undefinedError
    }
    
}
