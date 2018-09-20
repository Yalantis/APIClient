//
//  ErrorRecovererPlugin.swift
//  APIClient
//
//  Created by Roman Kyrylenko on 2/23/17.
//  Copyright © 2017 Eugene Andreyev. All rights reserved.
//

import Foundation

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
