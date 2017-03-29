//
//  StubbedAPIClient.swift
//  APIClient
//
//  Created by Roman Kyrylenko on 2/28/17.
//  Copyright © 2017 Eugene Andreyev. All rights reserved.
//

import BoltsSwift

public class StubbedAPIClient: NetworkClient {
    
    var responseDelay: TimeInterval
    
    public init(responseDelay: TimeInterval = 0.7) {
        self.responseDelay = responseDelay
    }
    
    private func delay(_ completion: @escaping () -> ()) {
        let deadlineTime = DispatchTime.now() + responseDelay
        DispatchQueue.global().asyncAfter(deadline: deadlineTime) {
            completion()
        }
    }
    
    public func execute<T, U: ResponseParser>(request: APIRequest, parser: U) -> Task<T> where U.Representation == T {
        let taskSource = TaskCompletionSource<T>()
        delay {
            let stub: T? = request.sampleStub()
            if let stub = stub {
                taskSource.set(result: stub)
                
                return
            }
            if let error = request.sampleStubError() {
                taskSource.set(error: error)
                
                return
            }
            
            taskSource.cancel()
        }
        
        return taskSource.task
    }
    
    public func execute<T, U: ResponseParser>(multipartRequest: APIRequest, parser: U) -> Task<T> where U.Representation == T {
        let taskSource = TaskCompletionSource<T>()
        delay {
            let stub: T? = multipartRequest.sampleStub()
            if let stub = stub {
                taskSource.set(result: stub)
                
                return
            }
            if let error = multipartRequest.sampleStubError() {
                taskSource.set(error: error)
                
                return
            }
            
            taskSource.cancel()
        }
        
        return taskSource.task
    }
    
    public func execute<T, U: ResponseParser>(downloadRequest: APIRequest, destinationFilePath destiantionPath: URL?, parser: U) -> Task<T> where U.Representation == T {
        let taskSource = TaskCompletionSource<T>()
        delay {
            let stub: T? = downloadRequest.sampleStub()
            if let stub = stub {
                taskSource.set(result: stub)
                
                return
            }
            if let error = downloadRequest.sampleStubError() {
                taskSource.set(error: error)
                
                return
            }
            
            taskSource.cancel()
        }
        
        return taskSource.task
    }
    
}
