//
//  ErrorDecoratorPlugin.swift
//
//  Created by Roman Kyrylenko on 3/6/17.
//

import Foundation

public protocol ErrorDecoratable {
    
    func decorate(_ error: Error) -> Error
}

public struct ErrorDecoratorPlugin: PluginType {
    
    private let decorator: ErrorDecoratable
    
    public init(decorator: ErrorDecoratable) {
        self.decorator = decorator
    }
    
    public func decorate(_ error: Error) -> Error {
        return decorator.decorate(error)
    }
}
