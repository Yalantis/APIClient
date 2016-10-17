import Foundation
import ObjectMapper

open class MappableParser<T: BaseMappable>: ResponseParser {
    
    public typealias Representation = T
    
    private let keyPath: String?
    
    public init(keyPath: String? = nil) {
        self.keyPath = keyPath
    }
    
    public func parse(_ object: AnyObject) throws -> T {
        func getValueForKeypath(_ object: AnyObject) -> AnyObject {
            if let keyPath = keyPath, let dictionary = object as? [String: AnyObject] {
                return dictionary[keyPath]!
            } else {
                return object
            }
        }
        
        if let representation = Mapper<T>().map(JSONObject: getValueForKeypath(object)) {
            return representation
        } else {
            throw NetworkError.resourceDeserializationError
        }
    }
    
}

open class MappableArrayParser<T: Collection>: ResponseParser where T.Iterator.Element: BaseMappable {
    
    public typealias Representation = T
    
    private let keyPath: String?
    
    public init(keyPath: String? = nil) {
        self.keyPath = keyPath
    }
    
    public func parse(_ object: AnyObject) throws -> T {
        func getValueForKeypath(_ object: AnyObject) -> AnyObject {
            if let keyPath = keyPath, let dictionary = object as? [String: AnyObject] {
                return dictionary[keyPath]!
            } else {
                return object
            }
        }
        if let Representation = Mapper<T.Generator.Element>().mapArray(JSONObject: getValueForKeypath(object)) as? T {
            return Representation
        } else {
            throw NetworkError.resourceDeserializationError
        }
    }
    
}
