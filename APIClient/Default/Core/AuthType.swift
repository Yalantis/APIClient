//
//  AuthType.swift
//  Pods
//
//  Created by Vodolazkyi Anton on 9/24/18.
//

import Foundation

// TODO: move to plugins directory
public enum AuthType {
    case `default`
    case basic
    case bearer
    case custom(key: String, valuePrefix: String?)
    
    var key: String {
        switch self {
        case .default, .basic, .bearer:
            return "Authorization"
        case .custom(let key, _):
            return key
        }
    }
    
    var valuePrefix: String? {
        switch self {
        case .default:
            return ""
        case .basic:
            return "Basic"
        case .bearer:
            return "Bearer"
        case .custom(_, let prefix):
            return prefix
        }
    }
}
