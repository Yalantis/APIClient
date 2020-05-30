//
//  APIClientAuthorizationTests.swift
//  APIClient-ExampleTests
//
//  Created by Roman Kyrylenko on 10/18/18.
//  Copyright © 2018 Yalantis. All rights reserved.
//

import XCTest
import APIClient
import Mockingjay

final class APIClientAuthorizationTests: XCTestCase {
    
    func test_SimpleRequest_NotAuthorizedButWithPlugin_ShouldNotHaveAuthorizationHeader() {
        let pluginExpectation = expectation(description: "plugin")
        let plugin = TokenExpectationPlugin { request in
            XCTAssertNil(request.headers?["Authorization"])
            pluginExpectation.fulfill()
        }
        let sut = APIClient(
            requestExecutor: AlamofireRequestExecutor(baseURL: URL(string: Constants.base)!),
            plugins: [AuthorizationPlugin(provider: TokenProvider()), plugin]
        )
        stub(http(.get, uri: Constants.base + Constants.user), json(["user": ["name": "bar", "email": "bob@me.com"]]))
        
        let responseExpectation = expectation(description: "response")
        sut.execute(request: GetUserRequest(), parser: DecodableParser<User>(keyPath: "user")) { result in
            responseExpectation.fulfill()
            XCTAssertNotNil(result.value)
            XCTAssertNil(result.error)
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func test_SimpleRequest_AuthorizedWithPlugin_ShouldHaveCorrectHeader() {
        let pluginExpectation = expectation(description: "plugin")
        let plugin = TokenExpectationPlugin { request in
            XCTAssertNotNil(request.headers)
            XCTAssertNotNil(request.headers?["Authorization"])
            XCTAssertEqual(request.headers?["Authorization"], "token")
            pluginExpectation.fulfill()
        }
        let sut = APIClient(
            requestExecutor: AlamofireRequestExecutor(baseURL: URL(string: Constants.base)!),
            plugins: [AuthorizationPlugin(provider: TokenProvider()), plugin]
        )
        stub(http(.get, uri: Constants.base + Constants.user), json(["user": ["name": "bar", "email": "bob@me.com"]]))
        
        let responseExpectation = expectation(description: "response")
        sut.execute(request: GetAuthorizedUserRequest(), parser: DecodableParser<User>(keyPath: "user")) { result in
            responseExpectation.fulfill()
            XCTAssertNotNil(result.value)
            XCTAssertNil(result.error)
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func test_MultipartRequest_WithAuthorizationPlugin_Passes() {
        let sut = APIClient(
            requestExecutor: AlamofireRequestExecutor(baseURL: URL(string: Constants.base)!),
            plugins: [AuthorizationPlugin(provider: TokenProvider())]
        )
        stub(http(.post, uri: Constants.base + Constants.user), json(["user": ["name": "bar", "email": "bob@me.com"]]))
        
        let responseExpectation = expectation(description: "Response")
        sut.execute(request: SimpleMultipartRequest(), parser: DecodableParser<User>(keyPath: "user")) { result in
            XCTAssertNotNil(result.value)
            XCTAssertNil(result.error)
            responseExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
}

final class TokenProvider: AuthorizationCredentialsProvider {
    
    var authorizationToken: String { return "token" }
    var authorizationType: AuthType { return .default }
}

struct TokenExpectationPlugin: PluginType {
    
    let willSend: (APIRequest) -> Void
    
    func willSend(_ request: APIRequest) {
        willSend(request)
    }
}

struct SimpleMultipartRequest: MultipartAPIRequest, AuthorizableRequest {
    
    let method: APIRequestMethod = .post
    let path = Constants.user
    
    var multipartFormData: ((MultipartFormDataType) -> Void) = { _ in }
    var progressHandler: ProgressHandler?
}

struct GetAuthorizedUserRequest: APIRequest, AuthorizableRequest {
    
    let path = Constants.user
}
