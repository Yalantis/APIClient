//
//  CustomError+Localization.swift
//  APIClient-Example
//
//  Created by Roman Kyrylenko on 1/23/18.
//  Copyright © 2018 Yalantis. All rights reserved.
//

import Foundation

extension CustomError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .connection:
            return "No Internet connection"
            
        case .server(let message):
            return message
            
        case .undefined:
            return "Undefined error occured. Please try again"
            
        case .unhandled(let error):
            return error.localizedDescription
            
        }
    }
    
}
