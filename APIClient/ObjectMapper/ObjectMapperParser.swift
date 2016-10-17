import Foundation
import ObjectMapper

class MappableParser<T: Mappable>: ResponseParser {
    
    typealias Representation = T
    
    private let keyPath: String?
    
    init(keyPath: String? = nil) {
        self.keyPath = keyPath
    }
    
    func parse(_ object: AnyObject) throws -> T {
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

class MappableArrayParser<T: Collection>: ResponseParser where T.Iterator.Element: Mappable {
    
    typealias Representation = T
    
    private let keyPath: String?
    
    init(keyPath: String? = nil) {
        self.keyPath = keyPath
    }
    
    func parse(_ object: AnyObject) throws -> T {
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
