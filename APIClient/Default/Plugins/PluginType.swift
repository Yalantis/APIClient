import BoltsSwift

/// Describes functions for the plugin
public protocol PluginType {

    /// Called to modify a request before sending
    func prepare(_ request: APIRequest) -> APIRequest
    
    /// Called immediately before a request is sent over the network.
    func willSend(_ request: APIRequest)
    
    /// Called to resolve error in case it happend.
    func resolve(_ error: Error) -> Task<Bool>
    
    /// Called to modify error in case it can't be resolved right before completion.
    func wrap(_ error: Error) -> Error
    
    /// Called to modify a result in case of success right before completion.
    func process<T>(_ result: T) -> T
}

public extension PluginType {
    
    func prepare(_ request: APIRequest) -> APIRequest {
        return request
    }
    
    func willSend(_ request: APIRequest) {
    }
    
    func resolve(_ error: Error) -> Task<Bool> {
        return Task(false)
    }
    
    func wrap(_ error: Error) -> Error {
        return error
    }
    
    func process<T>(_ result: T) -> T {
        return result
    }
    
}
