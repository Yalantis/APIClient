//
//  RequestExecutor.swift
//  RegistrationAndProfileFlow-Demo
//
//  Created by Eugene Andreyev on 5/13/16.
//  Copyright © 2016 Eugene Andreyev. All rights reserved.
//

import Foundation
import BoltsSwift

public protocol RequestExecutor {
    
    func executeRequest(request: APIRequest) -> Task<APIClient.HTTPResponse>
    func executeMultipartRequest(request: APIRequest) -> Task<APIClient.HTTPResponse>
    
}