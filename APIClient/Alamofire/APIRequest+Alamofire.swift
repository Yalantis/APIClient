import Foundation
import Alamofire

public extension APIRequest {

    var alamofireMethod: HTTPMethod {
      HTTPMethod(rawValue: method.rawValue.uppercased())
    }

    var alamofireEncoding: ParameterEncoding {
      encoding as? ParameterEncoding ?? URLEncoding.default
    }
    
    var alamofireHeaders: HTTPHeaders {
      HTTPHeaders(headers ?? [:])
    }
    
}

extension URLEncoding: APIRequestEncoding {}
extension PropertyListEncoder: APIRequestEncoding {}
extension JSONEncoding: APIRequestEncoding {}
