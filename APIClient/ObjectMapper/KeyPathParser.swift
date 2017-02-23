internal typealias JSON = [String: Any]

open class KeyPathParser {
    
    private let keyPath: String?
    
    public init(keyPath: String? = nil) {
        self.keyPath = keyPath
    }
    
    internal func valueForKeypath(in object: Any) -> Any? {
        if let keyPath = keyPath, let dictionary = object as? JSON {
            return dictionary[keyPath]
        } else {
            return object
        }
    }
    
}
