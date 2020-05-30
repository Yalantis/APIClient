import Foundation
import Alamofire

public extension APIRequest {

    var alamofireMethod: HTTPMethod {
        return HTTPMethod(rawValue: method.rawValue.uppercased())
    }
    
    var alamofireHeaders: HTTPHeaders? {
        guard let headers = headers else {
            return nil
        }
        
        return HTTPHeaders(headers)
    }

    var alamofireEncoding: ParameterEncoding {
        switch encoding {
        case .json: return Alamofire.JSONEncoding.default
        case .url: return Alamofire.URLEncoding.default
        }
    }
}
