//
//  APIRequest+Alamofire.swift
//  RegistrationAndProfileFlow-Demo
//
//  Created by Eugene Andreyev on 4/11/16.
//  Copyright © 2016 Eugene Andreyev. All rights reserved.
//

import Foundation
import Alamofire

extension APIRequest {
    
    var alamofireMethod: Alamofire.Method {
        switch method {
        case .GET:
            return .GET
            
        case .POST:
            return .POST
        
        case .PUT:
            return .PUT
            
        case .DELETE:
            
            return .DELETE
        }
    }
    
}
