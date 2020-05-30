//
//  APIClient_ExampleTests.swift
//  APIClient-ExampleTests
//
//  Created by Vodolazkyi Anton on 9/21/18.
//  Copyright © 2018 Yalantis. All rights reserved.
//

import XCTest
@testable import APIClient_Example
import APIClient
import Mockingjay

struct Constants {
    
    static let base =  "https://apiclient.com/api"
    static let user = "/user"
    static let user2 = "/user2"
    static let restore = "/restore"
}

class APIClient_ExampleTests: XCTestCase {
    
    var sut: NetworkClient!
    
    override func setUp() {
        super.setUp()

        sut = APIClient(
            requestExecutor: AlamofireRequestExecutor(baseURL: URL(string: Constants.base)!)
        )
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    func test_GetUser_WhenSuccessful_CreatesUser() {
        let body = ["user": ["name": "Bob", "email": "bob@me.com"]]
        stub(http(.get, uri: Constants.base + Constants.user), json(body))
        
        let userExpectation = expectation(description: "User")
        var expectedUser: User?
        
        sut.execute(request: GetUserRequest(), parser: DecodableParser<User>(keyPath: "user")) { result in
            expectedUser = result.value
            userExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { _ in
            XCTAssertEqual(expectedUser?.name, "Bob")
        }
    }
    
    func test_GetUser_WhenJSONKeyNotFound_ReturnError() {
        let body = ["user": ["foo": "bar", "email": "bob@me.com"]]
        stub(http(.get, uri: Constants.base + Constants.user), json(body))

        let keyExpectation = expectation(description: "Key")
        var notFoundKey = ""
        
        sut.execute(request: GetUserRequest(), parser: DecodableParser<User>(keyPath: "user")) { result in
            XCTAssertNotNil(result.error)
            
            let error = result.error!
            switch error {
            case .serialization(let error):
                switch error {
                case .parsing(let error):
                    if case let DecodingError.keyNotFound(keys, _) = error as! DecodingError {
                        notFoundKey = keys.stringValue
                    }
                default: break
                }
            default: break
            }
            
            keyExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { _ in
            XCTAssertEqual(notFoundKey, "name")
        }
    }

    func test_GetUser_WhenRequestCanceled_ReturnError() {
        stub(everything, http(NSURLErrorCancelled))
        
        let errorExpectation = expectation(description: "Error")
        var isCanceledError = false
        
        let request = sut.execute(request: GetUserRequest(), parser: DecodableParser<User>(keyPath: "user")) { result in
            XCTAssertNotNil(result.error)
            
            let error = result.error!
            switch error {
            case .network(let error):
                switch error {
                case .canceled: isCanceledError = true
                default: break
                }
            default: break
            }
            
            errorExpectation.fulfill()
        }
        request.cancel()
        
        waitForExpectations(timeout: 1) { _ in
            XCTAssertEqual(isCanceledError, true)
        }
    }
    
    func test_GetUser_WhenTokenIsInvalid_ReturnsError() {
        stub(everything, failure(NSError(domain: "", code: 401, userInfo: nil)))
        
        let errorExpectation = expectation(description: "error")
        var catchedErrorIsUnauthorized = false

        sut.execute(request: GetUserRequest(), parser: DecodableParser<User>(keyPath: "user")) { result in
            XCTAssertNotNil(result.error)
            
            let error = result.error!
            switch error {
            case .network(let error):
                switch error {
                case .unauthorized: catchedErrorIsUnauthorized = true
                default: break
                }
            default: break
            }
            errorExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { _ in
            XCTAssertEqual(catchedErrorIsUnauthorized, true)
        }
    }
}

struct User: Codable {
    
    let name: String
    let email: String
}

struct GetUserRequest: APIRequest {
    
    let method: APIRequestMethod = .get
    let path = Constants.user
}

struct WrongGetUserRequest: APIRequest {
    
    let method: APIRequestMethod = .post
    let path = Constants.user
    let parser = DecodableParser<User>(keyPath: "user")
}
