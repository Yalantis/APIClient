import Foundation
import ObjectMapper

public class ImmutableMappableParser<T: ImmutableMappable>: KeyPathParser, ResponseParser {
    
    public typealias Representation = T
    
    public func parse(_ object: AnyObject) throws -> T {
        guard let json = valueForKeypath(in: object) as? JSON else {
            throw ParserError.parsingJson
        }
        
        do {
            return try T(JSON: json)
        } catch {
            throw ParserError.parsingInstance
        }
    }
}

public class ImmutableMappableArrayParser<T: ImmutableMappable>: KeyPathParser, ResponseParser {
    
    public typealias Representation = [T]
    
    public func parse(_ object: AnyObject) throws -> [T] {
        guard let jsonArray = valueForKeypath(in: object) as? [JSON] else {
            throw ParserError.parsingJson
        }
        
        do {
            return try jsonArray.map({ try T(JSON: $0) })
        } catch {
            throw ParserError.parsingArray
        }
    }
}
