import Foundation
import Alamofire

public extension APIRequest {

    var alamofireMethod: HTTPMethod {
        return HTTPMethod(rawValue: method.rawValue.uppercased()) ?? .get
    }

    var alamofireEncoding: ParameterEncoding {
        return encoding as? ParameterEncoding ?? URLEncoding.default
    }
    
}

extension URLEncoding: APIRequestEncoding {}
extension PropertyListEncoding: APIRequestEncoding {}
extension JSONEncoding: APIRequestEncoding {}
