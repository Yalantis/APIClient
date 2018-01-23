//
//  NetworkClientInjector.swift
//  APIClient-Example
//
//  Created by Roman Kyrylenko on 1/23/18.
//  Copyright © 2018 Yalantis. All rights reserved.
//

import Foundation
import APIClient

struct NetworkClientInjector {
    
    static var geoServiceNetworkClient: NetworkClient = APIClient(
        requestExecutor: AlamofireRequestExecutor(baseURL: Constants.API.geoServiceBaseURL),
        plugins: [ErrorProcessor()]
    )
    
    static var ipServiceNetworkClient: NetworkClient = APIClient(
        requestExecutor: AlamofireRequestExecutor(baseURL: Constants.API.ipServiceBaseURL),
        plugins: [ErrorProcessor()]
    )
    
}

protocol NetworkClientInjectable {}

extension NetworkClientInjectable {
    
    var geoServiceNetworkClient: NetworkClient {
        return NetworkClientInjector.geoServiceNetworkClient
    }
    var ipServiceNetworkClient: NetworkClient {
        return NetworkClientInjector.ipServiceNetworkClient
    }
    
}

