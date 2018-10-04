import Foundation
import Alamofire

public extension APIRequest {

    public var alamofireMethod: HTTPMethod {
        return HTTPMethod(rawValue: method.rawValue.uppercased()) ?? .get
    }

    public var alamofireEncoding: ParameterEncoding {
        return encoding as? ParameterEncoding ?? URLEncoding.default
    }
    
}

extension URLEncoding: APIRequestEncoding {}
extension PropertyListEncoding: APIRequestEncoding {}
extension JSONEncoding: APIRequestEncoding {}
