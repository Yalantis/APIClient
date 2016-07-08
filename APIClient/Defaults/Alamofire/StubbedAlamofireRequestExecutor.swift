//
//  StubbedAlamofireRequestExecutor.swift
//  RegistrationAndProfileFlow-Demo
//
//  Created by Eugene Andreyev on 5/13/16.
//  Copyright © 2016 Eugene Andreyev. All rights reserved.
//

import Foundation
import OHHTTPStubs
import BoltsSwift
import APIClient

public class StubbedAlamofireRequestExecutor: AlamofireRequestExecutor {
    
    override public func executeRequest(request: APIRequest) -> Task<(NSHTTPURLResponse, NSData)> {
        stub(isHost("ror-tpl.herokuapp.com")) { _ in
            let pathString = request.path.stringByReplacingOccurrencesOfString("/", withString: "_").lowercaseString
            let methodString = "_" + String(request.method).lowercaseString
            guard let path = OHPathForFile(pathString + methodString + ".json", self.dynamicType) else {
                preconditionFailure("Could not load file")
            }
            
            return OHHTTPStubsResponse(fileAtPath: path, statusCode: 200, headers: [ "Content-Type": "application/json" ])

        }
        
        return super.executeRequest(request)
    }
    
}
