//
//  APIRequest+Stub.swift
//  APIClient
//
//  Created by Roman Kyrylenko on 2/28/17.
//  Copyright © 2017 Eugene Andreyev. All rights reserved.
//

import Foundation

public protocol StubbedAPIRequest: APIRequest {
    
    var stub: Stub? { get }
    
}
