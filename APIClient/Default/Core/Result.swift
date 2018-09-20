//
//  Result.swift
//  APIClient
//
//  Created by Vodolazkyi Anton on 9/19/18.
//

import Foundation

public enum Result<T> {
    
    case success(T)
    case failure(Error)
}

extension Result {
    
    public var value: T? {
        switch self {
        case .success(let result): return result
        case .failure: return nil
        }
    }
    
    public var error: Error? {
        switch self {
        case .success: return nil
        case .failure(let error): return error
        }
    }
}

extension Result {
    
    @discardableResult
    public func map<U>(_ f: (T) -> U) -> Result<U> {
        switch self {
        case .success(let t): return .success(f(t))
        case .failure(let error): return .failure(error)
        }
    }
    
    @discardableResult
    public func map<U>(_ f: () -> U) -> Result<U> {
        switch self {
        case .success: return .success(f())
        case .failure(let error): return .failure(error)
        }
    }
    
    @discardableResult
    public func next<U>(_ f: (T) -> Result<U>) -> Result<U> {
        switch self {
        case .success(let t): return f(t)
        case .failure(let error): return .failure(error)
        }
    }
    
    @discardableResult
    public func next<U>(_ f: () -> Result<U>) -> Result<U> {
        switch self {
        case .success: return f()
        case .failure(let error): return .failure(error)
        }
    }
    
    @discardableResult
    public func onError(_ f: (Error) -> Error) -> Result<T> {
        switch self {
        case .success(let value): return .success(value)
        case .failure(let error): return .failure(error)
        }
    }
    
    @discardableResult
    public func require() -> T {
        switch self {
        case .success(let value): return value
        case .failure(let error): fatalError("Value is required: \(error)")
        }
    }
    
}
