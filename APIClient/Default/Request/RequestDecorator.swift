import Foundation

public protocol RequestDecorator {
    
    func decoratedRequest(from request: APIRequest) -> APIRequest
    
}
