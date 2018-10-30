//
//  ErrorRecovererPlugin.swift
//  APIClient
//
//  Created by Roman Kyrylenko on 2/23/17.
//  Copyright © 2017 Yalantis. All rights reserved.
//

import Foundation

public protocol ErrorRecovering {
    
    func canRecover(from error: Error) -> Bool
    func recover(from error: Error) -> Bool
}

public final class ErrorRecovererPlugin: PluginType {
    
    private let errorRecoverer: ErrorRecovering
    
    public init(errorRecoverer: ErrorRecovering) {
        self.errorRecoverer = errorRecoverer
    }
    
    public func resolve(_ error: Error) -> Bool {
        if errorRecoverer.canRecover(from: error) {
            return errorRecoverer.recover(from: error)
        }
        
        return false
    }
}
