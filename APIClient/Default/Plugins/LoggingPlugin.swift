//
//  LoggingPlugin.swift
//  APIClient
//
//  Created by Roman Kyrylenko on 2/28/17.
//  Copyright © 2017 Eugene Andreyev. All rights reserved.
//

import BoltsSwift

public final class LoggingPlugin: PluginType {
    
    private let outputClosure: (String) -> Void
    
    public init(outputClosure: ((String) -> ())? = nil) {
        if let outputClosure = outputClosure {
            self.outputClosure = outputClosure
        } else {
            self.outputClosure = { string in
                print("----------------------------")
                print("LoggingPlugin [\(Date())]: \(string)")
                print("----------------------------")
            }
        }
    }
    
    public func prepare(_ request: APIRequest) -> APIRequest {
        outputClosure("Preparing request - \(describe(request))")
        
        return request
    }
    
    public func willSend(_ request: APIRequest) {
        outputClosure("Ready to send - \(describe(request))")
    }
    
    public func didReceive(response: APIClient.HTTPResponse) {
        outputClosure("Received - \(describe(response))")
    }
    
    public func resolve(_ error: Error) -> Task<Bool> {
        outputClosure("Attempt to resolve - \(error)")
        
        return Task(false)
    }
    
    public func processError(_ response: APIClient.HTTPResponse) -> Error? {
        outputClosure("Received error - \(describe(response))")
        
        return nil
    }
    
    public func process<T>(_ result: T) -> T {
        outputClosure("Successfully received - \(result)")
        
        return result
    }
 
    private func describe(_ request: APIRequest) -> String {
        return "\(request)"
    }
    
    private func describe(_ response: APIClient.HTTPResponse) -> String {
        return "\(response)"
    }
    
}
