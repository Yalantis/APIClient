//
//  CustomError.swift
//  APIClient-Example
//
//  Created by Roman Kyrylenko on 1/23/18.
//  Copyright © 2018 Yalantis. All rights reserved.
//

import ObjectMapper

public enum CustomError: Error {
    
    case undefined
    case connection
    case unhandled(error: Error)
    case server(message: String)
    
    init?(object: Any) {
        guard let json = object as? [String: Any],
            let errorMessage = json["msg"] as? String else {
                return nil
        }
        
        self = .server(message: errorMessage)
    }
    
}
