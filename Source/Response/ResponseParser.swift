//
//  ResponseParser.swift
//  RegistrationAndProfileFlow-Demo
//
//  Created by Eugene Andreyev on 6/27/16.
//  Copyright © 2016 Eugene Andreyev. All rights reserved.
//

import Foundation
import ObjectMapper

public protocol ResponseParser {
    
    associatedtype Representation
    
    func parse(object: AnyObject) throws -> Representation
    
}

class MappableParser<T: Mappable>: ResponseParser {
    
    typealias Representation = T
    
    private let keyPath: String?
    
    init(keyPath: String? = nil) {
        self.keyPath = keyPath
    }
    
    func parse(object: AnyObject) throws -> T {
        func getValueForKeypath(object: AnyObject) -> AnyObject {
            if let keyPath = keyPath, let dictionary = object as? [String: AnyObject] {
                return dictionary[keyPath]!
            } else {
                return object
            }
        }
        
        if let representation = Mapper<T>().map(getValueForKeypath(object)) {
            return representation
        } else {
            throw APIError.ResourceDeserialization
        }
    }
    
}

class MappableArrayParser<T: CollectionType where T.Generator.Element: Mappable>: ResponseParser {
    
    typealias Representation = T
    
    private let keyPath: String?
    
    init(keyPath: String? = nil) {
        self.keyPath = keyPath
    }
    
    func parse(object: AnyObject) throws -> T {
        func getValueForKeypath(object: AnyObject) -> AnyObject {
            if let keyPath = keyPath, let dictionary = object as? [String: AnyObject] {
                return dictionary[keyPath]!
            } else {
                return object
            }
        }
        
        if let Representation = Mapper<T.Generator.Element>().mapArray(getValueForKeypath(object)) as? T {
            return Representation
        } else {
            throw APIError.ResourceDeserialization
        }
    }
    
}

struct EmptyParser: ResponseParser {
    
    func parse(object: AnyObject) throws -> Bool {
        return true
    }
    
}

struct JSONParser: ResponseParser {
    
    func parse(object: AnyObject) throws -> [String: AnyObject] {
        return object as! [String: AnyObject]
    }
    
}
