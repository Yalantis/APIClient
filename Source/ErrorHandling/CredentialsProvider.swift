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
    
    func restoreCredentials() -> Task<Bool>
    
}

class CredentialsProducer: CredentialsProducing {
    
    var token: String {
        return credentialStorage.userSessionCredential?.token ?? ""
    }
    
    private let credentialStorage: CredentialStorage
    private lazy var apiClient: APIClient = {
        return APIClient(requestExecutor: AlamofireRequestExecutor(baseURL: Constants.API.baseURL))
    }()
    
    init(credentialStorage: CredentialStorage) {
        self.credentialStorage = credentialStorage
    }
    
    func restoreCredentials() -> Task<Bool> {
        if let credential = credentialStorage.userSessionCredential {
            let loginRequest = CreateSessionRequest(credential: credential)
            
            return apiClient.executeRequest(loginRequest).continueWithTask(
                continuation: { task -> Task<Bool> in
                    if let result = task.result, let newToken = result["token"] as? String {
                        var newCredential = credential
                        newCredential.token = newToken
                        self.credentialStorage.userSessionCredential = newCredential
                        
                        return Task<Bool>(true)
                    }
                    
                    return Task<Bool>(false)
                }
            )
        }
        
        return Task<Bool>(false)
    }
    
}
