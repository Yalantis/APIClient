import Foundation
import Alamofire

public extension APIRequest {
    
    public var alamofireMethod: Alamofire.HTTPMethod {
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
