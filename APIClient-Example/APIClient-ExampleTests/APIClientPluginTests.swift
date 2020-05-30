//
//  APIClientPluginTests.swift
//  APIClient-ExampleTests
//
//  Created by Vodolazkyi Anton on 9/21/18.
//  Copyright © 2018 Yalantis. All rights reserved.
//

import XCTest
import APIClient
import Mockingjay

class APIClientPluginTests: XCTestCase {
    
    var sut: NetworkClient!
    
    override func setUp() {
        super.setUp()

        sut = APIClient(
            requestExecutor: AlamofireRequestExecutor(baseURL: URL(string: Constants.base)!),
            plugins: [TestPlugin()]
        )
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_Plugin_UsesExpectedRequestSubstitute() {
        let body = ["user": ["name": "Bob", "email": "bob@me.com"]]
        stub(http(.get, uri: Constants.base + Constants.user), json(body))
        
        let userExpectation = expectation(description: "User")
        var expectedUser: User?
        
        sut.execute(request: WrongGetUserRequest(), parser: DecodableParser<User>(keyPath: "user")) { result in
            expectedUser = result.value
            userExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { _ in
            XCTAssertEqual(expectedUser?.name, "Bob")
        }
    }
    
}

struct TestPlugin: PluginType {
    
    func prepare(_ request: APIRequest) -> APIRequest {
        return GetUserRequest()
    }
    
}
