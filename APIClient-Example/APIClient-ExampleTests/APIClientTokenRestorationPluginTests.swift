//
//  APIClientTokenRestorationPluginTests.swift
//  APIClient-ExampleTests
//
//  Created by Vodolazkyi Anton on 9/24/18.
//  Copyright © 2018 Yalantis. All rights reserved.
//

import XCTest
@testable import APIClient_Example
import YALAPIClient
import Mockingjay

class APIClientTokenRestorationPluginTests: XCTestCase {
    
    var session: UserSession!
    
    override func setUp() {
        super.setUp()
        
        session = UserSession()
    }
    
    override func tearDown() {
        session = nil
        super.tearDown()
    }
    
    func test_TokenRestoration_WhenTokenExpiredAndRestoreRequestNotProvided_TerminateSession() {
        let sut = APIClient(
            requestExecutor: AlamofireRequestExecutor(baseURL: URL(string: Constants.base)!),
            plugins: [ErrorProcessor(), RestorationTokenPlugin(credentialProvider: session)]
        )
        stub(everything, failure(NSError(domain: "", code: 401, userInfo: nil)))

        let tokenExpectation = expectation(description: "Token")
        
        sut.execute(request: GetProfileRequest(), parser: DecodableParser<User>(keyPath: "user")) { result in
            tokenExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { _ in
            XCTAssertNil(self.session.accessToken)
        }
    }

    func test_TokenRestoratin_WhenTokenExpired_RestoreToken() {
        let decorationPlugin = RestorationTokenPlugin(credentialProvider: session)
        let sut = APIClient(
            requestExecutor: AlamofireRequestExecutor(baseURL: URL(string: Constants.base)!),
            plugins: [ErrorProcessor(), decorationPlugin]
        )
        
        decorationPlugin.restorationResultProvider = { (completion: @escaping (Result<Auth>) -> Void) -> Void in
            self.stubSuccessfulAuth()
            
            let restoreRequest = RestoreRequest()
            sut.execute(request: restoreRequest, parser: DecodableParser<Credentials>(), completion: { result in
                self.stubSuccessfulUser()
                completion(result.map { $0 as Auth })
            })
        }
        stub(everything, failure(NSError(domain: "", code: 401, userInfo: nil)))

        let tokenExpectation = expectation(description: "Token")
        sut.execute(request: GetProfileRequest(), parser: DecodableParser<User>(keyPath: "user")) { result in
            tokenExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { _ in
            XCTAssertEqual(self.session.accessToken, "333")
            XCTAssertEqual(self.session.exchangeToken, "444")
        }
    }
    
    private func stubSuccessfulAuth() {
        let body = ["exchange_token": "444", "access_token": "333"]
        stub(http(.put, uri: Constants.base + Constants.restore), json(body))
    }
    
    private func stubSuccessfulUser() {
        let body = ["user": ["name": "bar", "email": "bob@me.com"]]
        stub(http(.get, uri: Constants.base + Constants.user), json(body))
    }
    
}

struct GetProfileRequest: APIRequest, CredentialProvidableRequest {
    
    let method: APIRequestMethod = .get
    let path = Constants.user

}

struct RestoreRequest: APIRequest, CredentialProvidableRequest {
    
    let method: APIRequestMethod = .put
    let path = Constants.restore
    
}

struct Credentials: Codable, Auth {
    
    var exchangeToken: String
    var accessToken: String
    
}

class UserSession: AccessCredentialsProvider {
    
    var accessToken: String? = "123"
    var exchangeToken: String? = "123"
    
    func commitCredentialsUpdate(_ update: (AccessCredentialsProvider) -> Void) {
        update(self)
    }
    
    func invalidate() {
        accessToken = nil
        exchangeToken = nil
    }
    
}
