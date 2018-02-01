import Foundation
import ObjectMapper
import APIClient

public enum ParserError: Error {
    
    case parsingInstance, parsingArray, parsingJson
    
}

open class MappableParser<T: BaseMappable>: KeyPathParser, ResponseParser {
    
    public typealias Representation = T
    
    public func parse(_ object: AnyObject) throws -> T {
        guard let json = valueForKeypath(in: object) as? JSON else {
            throw ParserError.parsingJson
        }
        
        if let representation = Mapper<T>().map(JSONObject: json) {
            return representation
        } else {
            throw ParserError.parsingInstance
        }
    }
    
}

open class MappableArrayParser<T: Collection>: KeyPathParser, ResponseParser where T.Iterator.Element: BaseMappable {
    
    public typealias Representation = T
    
    public func parse(_ object: AnyObject) throws -> T {
        guard let jsonArray = valueForKeypath(in: object) as? [JSON] else {
            throw ParserError.parsingJson
        }
        
        if let representation = Mapper<T.Iterator.Element>().mapArray(JSONObject: jsonArray) as? T {
            return representation
        } else {
            throw ParserError.parsingArray
        }
    }
    
}
