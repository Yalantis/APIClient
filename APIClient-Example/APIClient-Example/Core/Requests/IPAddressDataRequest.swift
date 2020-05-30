//
//  IPAddressDataRequest.swift
//  APIClient-Example
//
//  Created by Roman Kyrylenko on 1/23/18.
//  Copyright © 2018 Yalantis. All rights reserved.
//

import Foundation
import APIClient

struct IPAddressDataRequest: APIRequest {
    
    let method: APIRequestMethod = .get
    let path: String
    
    init(ipAddress: String) {
        path = ipAddress
    }
}
