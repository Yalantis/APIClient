import Foundation
import Alamofire

public extension APIRequest {

    var alamofireMethod: HTTPMethod {
        return HTTPMethod(rawValue: method.rawValue.uppercased()) ?? .get
    }

    var alamofireEncoding: ParameterEncoding {
        switch encoding {
        case .json: return Alamofire.JSONEncoding.default
        case .url: return Alamofire.URLEncoding.default
        case .propertyList: return Alamofire.PropertyListEncoding.default
        }
    }
}
