//
//  APIClientHaltingRequestsTests.swift
//  APIClient-ExampleTests
//
//  Created by Roman Kyrylenko on 10/17/18.
//  Copyright © 2018 Yalantis. All rights reserved.
//

import XCTest
import YALAPIClient
import Mockingjay

final class APIClientHaltingRequestsTests: XCTestCase {
    
    func test_RequestHalting_WhenTokenExpired_HaltRequestUntilRestored() {
        let session = UserSession()
        let decorationPlugin = RestorationTokenPlugin(credentialProvider: session)
        let sut = APIClient(
            requestExecutor: AlamofireRequestExecutor(baseURL: URL(string: Constants.base)!),
            plugins: [decorationPlugin]
        )
        let firstRequestExpectation = expectation(description: "first request")
        let secondRequestExpectation = expectation(description: "second request")
        let executionQueue = DispatchQueue(label: "execution queue")
        let restorationQueue = DispatchQueue(label: "restoration queue")
        
        var attemptsToRestore = 0
        decorationPlugin.restorationResultProvider = { (completion: @escaping (Result<TokenType>) -> Void) -> Void in
            restorationQueue.async {
                sleep(2)
                attemptsToRestore += 1
                self.stub(http(.put, uri: Constants.base + Constants.restore), json(["exchange_token": "444", "access_token": "333"]))
                sut.execute(request: RestoreRequest(), parser: DecodableParser<Credentials>(), completion: { result in
                    self.stub(http(.get, uri: Constants.base + Constants.user), json(["user": ["name": "bar", "email": "bob@me.com"]]))
                    self.stub(http(.get, uri: Constants.base + Constants.user2), json(["user": ["name": "bar2", "email": "bob2@me.com"]]))
                    completion(result.map { $0 as TokenType })
                })
            }
        }
        stub(everything, failure(NSError(domain: "", code: 401, userInfo: nil)))
        executionQueue.async {
            sut.execute(request: GetProfileRequest(), parser: DecodableParser<User>(keyPath: "user")) { result in
                XCTAssertNil(result.error)
                XCTAssertEqual(result.value?.name, "bar")
                firstRequestExpectation.fulfill()
            }
            sleep(1)
            sut.execute(request: GetProfile2Request(), parser: DecodableParser<User>(keyPath: "user")) { result in
                XCTAssertNil(result.error)
                XCTAssertEqual(result.value?.name, "bar2")
                secondRequestExpectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 3) { error in
            XCTAssertNil(error)
            XCTAssertEqual(attemptsToRestore, 1)
            XCTAssertEqual(session.accessToken, "333")
            XCTAssertEqual(session.exchangeToken, "444")
        }
    }
}
