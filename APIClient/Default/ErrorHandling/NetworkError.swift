import Foundation

public enum APIErrorCode: String {
    
    case unauthorized = "authorization_error"
    
    case undefined = "undefined"
    case resourceDeserialization = "deserialization"
    case resourceInvalidResponse = "invalid_response"
    
}

public struct NetworkError: Error, Hashable, CustomStringConvertible {
    
    public var _domain: String {
        return String(describing: type(of: self))
    }
    
    public var code: APIErrorCode
    
    public var metaErrors: [String: NetworkError]?
    public var serverDescription: String?
    
    // MARK: Hashable
    
    public var hashValue: Int {
        return code.rawValue.hashValue
    }
    
    // MARK: Lifecycle
    
    public init(code: APIErrorCode, description: String? = nil, metaErrors: [String: NetworkError]? = nil) {
        self.code = code
        self.serverDescription = description
        self.metaErrors = metaErrors
    }
    
    // MARK: Defaults
    
    public static let undefinedError = NetworkError(code: .undefined, description: nil, metaErrors: nil)
    public static let resourceDeserializationError = NetworkError(
        code: .resourceDeserialization,
        description: nil,
        metaErrors: nil
    )
    
    // MARK: CustomStringConvertible
    
    public var description: String {
        switch self.code {
        case .resourceDeserialization:
            return NSLocalizedString("error.deserialization", comment: "")
            
        default:
            return NSLocalizedString("error.undefiend", comment: "")
        }
    }
 
    static public func ==(lhs: NetworkError, rhs: NetworkError) -> Bool {
        return lhs.code == rhs.code
    }
    
}

extension NetworkError {
    
    init?(dictionary: [String: AnyObject]) {
        if let rawCode = dictionary["code"] as? String, let code = APIErrorCode(rawValue: rawCode) {
            self.code = code
        } else {
            return nil
        }
        serverDescription = dictionary["description"] as? String
        if let metaDictionary = dictionary["meta"] as? [String: [String: AnyObject]] {
            metaErrors = metaDictionary.reduce(
                [String: NetworkError](),
                { previousValue, element in
                    var errors = previousValue
                    errors[element.0] = NetworkError(dictionary: element.1)
                    
                    return errors
                }
            )
        }
    }
    
}
