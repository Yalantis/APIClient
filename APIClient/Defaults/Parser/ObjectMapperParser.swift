//
// Created by Eugene Andreyev on 7/8/16.
// Copyright (c) 2016 Eugene Andreyev. All rights reserved.
//

import Foundation
import ObjectMapper

public class MappableParser<T: Mappable>: ResponseParser {

    public typealias Representation = T

    private let keyPath: String?

    public init(keyPath: String? = nil) {
        self.keyPath = keyPath
    }

    public func parse(object: AnyObject) throws -> T {
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

public class MappableArrayParser<T: CollectionType where T.Generator.Element: Mappable>: ResponseParser {

    public typealias Representation = T

    private let keyPath: String?

    init(keyPath: String? = nil) {
        self.keyPath = keyPath
    }

    public func parse(object: AnyObject) throws -> T {
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
