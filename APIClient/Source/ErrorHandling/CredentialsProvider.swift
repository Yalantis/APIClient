//
//  CredentialsProvider.swift
//  RegistrationAndProfileFlow-Demo
//
//  Created by Eugene Andreyev on 6/27/16.
//  Copyright © 2016 Eugene Andreyev. All rights reserved.
//

import Foundation
import BoltsSwift

public protocol CredentialsProducing {
    
    var token: String { get }
    
    func decoratedRequest(request: APIRequest) -> APIRequest
    
    func restoreCredentials() -> Task<Bool>
    func carRecoverFromError(error: ErrorType) -> Bool
    
}
