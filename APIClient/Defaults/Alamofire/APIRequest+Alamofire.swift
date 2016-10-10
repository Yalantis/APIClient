import Foundation
import Alamofire

extension APIRequest {
    
    var alamofireMethod: Alamofire.HTTPMethod {
        switch method {
        case .get:
            return .get
            
        case .post:
            return .post
            
        case .put:
            return .put
            
        case .delete:
            
            return .delete
        }
    }
    
}
