//
//  APIClientHaltingRequestsTests.swift
//  APIClient-ExampleTests
//
//  Created by Roman Kyrylenko on 10/17/18.
//  Copyright © 2018 Yalantis. All rights reserved.
//

import XCTest
import APIClient
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
        decorationPlugin.restorationResultProvider = { (completion: @escaping (Result<TokenType, NetworkClientError>) -> Void) -> Void in
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
            sut.execute(request: GetUserRequest(), parser: DecodableParser<User>(keyPath: "user")) { result in
                XCTAssertNil(result.error)
                XCTAssertEqual(result.value?.name, "bar")
                firstRequestExpectation.fulfill()
            }
            sleep(1)
            sut.execute(request: GetAuthorizedUser2Request(), parser: DecodableParser<User>(keyPath: "user")) { result in
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
    
    func test_RequestsCancelling_WhenCancellationEnabled_ShouldCancellAllNewRequests() {
        AuthorizationPlugin.requestsCancellingTimespan = 2
        let sut = APIClient(
            requestExecutor: AlamofireRequestExecutor(baseURL: URL(string: Constants.base)!),
            plugins: [AuthorizationPlugin(provider: TokenProvider(), shouldCancelRequestIfFailed: true)]
        )
        let firstRequestExpectation = expectation(description: "first request")
        let secondRequestExpectation = expectation(description: "second request")
        let thirdRequestExpectation = expectation(description: "third request")
        let executionQueue = DispatchQueue(label: "execution queue")
        
        stub(everything, failure(NSError(domain: "", code: 401, userInfo: nil)))
        executionQueue.async {
            sut.execute(request: GetAuthorizedUserRequest(), parser: DecodableParser<User>(keyPath: "user")) { result in
                XCTAssertNotNil(result.error)
                
                let error: NetworkClientError = result.error!
                switch error {
                case .network(let error):
                    switch error {
                    case .unauthorized: break
                    default: XCTFail("unexpected error: \(error)")
                    }
                default: XCTFail("unexpected error: \(error)")
                }
                firstRequestExpectation.fulfill()
            }
            sleep(1)
            sut.execute(request: GetAuthorizedUserRequest(), parser: DecodableParser<User>(keyPath: "user")) { result in
                XCTAssertNotNil(result.error)
                
                let error: NetworkClientError = result.error!
                switch error {
                case .network(let error):
                    switch error {
                    case .canceled: break
                    default: XCTFail("unexpected error: \(error)")
                    }
                default: XCTFail("unexpected error: \(error)")
                }
                secondRequestExpectation.fulfill()
            }
            sut.execute(request: GetAuthorizedUserRequest(), parser: DecodableParser<User>(keyPath: "user")) { result in
                XCTAssertNotNil(result.error)
                
                let error: NetworkClientError = result.error!
                switch error {
                case .network(let error):
                    switch error {
                    case .canceled: break
                    default: XCTFail("unexpected error: \(error)")
                    }
                default: XCTFail("unexpected error: \(error)")
                }
                thirdRequestExpectation.fulfill()
            }
        }
        waitForExpectations(timeout: 3) { error in
            XCTAssertNil(error)
        }
    }
}

struct GetAuthorizedUser2Request: APIRequest, AuthorizableRequest {
    
    let method: APIRequestMethod = .get
    let path = Constants.user2
}

extension Result {
    
    var value: Success? {
        switch self {
        case .success(let result): return result
        case .failure: return nil
        }
    }
    
    var error: Failure? {
        switch self {
        case .success: return nil
        case .failure(let error): return error
        }
    }
}
