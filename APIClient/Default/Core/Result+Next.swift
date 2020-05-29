extension Result {
    
    var value: Success? {
        switch self {
        case .success(let result): return result
        case .failure: return nil
        }
    }
    
    var error: Failure? {
        switch self {
        case .success: return nil
        case .failure(let error): return error
        }
    }
    
    @discardableResult
    func next<U>(_ f: (Success) -> Result<U, Failure>) -> Result<U, Failure> {
        switch self {
        case .success(let t): return f(t)
        case .failure(let error): return .failure(error)
        }
    }
}
