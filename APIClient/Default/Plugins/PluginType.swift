//
//  PluginType.swift
//  APIClient
//
//  Created by Roman Kyrylenko on 2/23/17.
//  Copyright © 2017 Eugene Andreyev. All rights reserved.
//

import BoltsSwift

/// Describes functions of the plugin for APIClient
public protocol PluginType {

    /// Called to modify a request before sending
    func prepare(_ request: APIRequest) -> APIRequest
    
    /// Called immediately before a request is sent over the network.
    func willSend(_ request: APIRequest)
    
    /// Called immediately after data received.
    func didReceive(response: APIClient.HTTPResponse)
    
    /// Called to resolve error in case it happend.
    func resolve(_ error: Error) -> Task<Bool>
    
    /// Called to provide error in case response isn't successful.
    func processError(_ response: APIClient.HTTPResponse) -> Error?
    
    /// Called to modify a result in case of success right before completion.
    func process<T>(_ result: T) -> T
}

public extension PluginType {
    
    func prepare(_ request: APIRequest) -> APIRequest {
        return request
    }
    
    func willSend(_ request: APIRequest) {
    }
    
    func didReceive(response: APIClient.HTTPResponse) {
    }
    
    func resolve(_ error: Error) -> Task<Bool> {
        return Task(false)
    }
    
    func processError(_ response: APIClient.HTTPResponse) -> Error? {
        return nil
    }
    
    func process<T>(_ result: T) -> T {
        return result
    }
    
}
