import Foundation
import BoltsSwift

open class APIClient: NSObject, NetworkClient {
    
    public typealias HTTPResponse = (httpResponse: HTTPURLResponse, data: Data)
    
    fileprivate let responseExecutor: Executor = .queue(DispatchQueue(label: "APIClientQueue", attributes: .concurrent))
    fileprivate let requestExecutor: RequestExecutor
    fileprivate let deserializer: Deserializer
    fileprivate let plugins: [PluginType]
    
    // MARK: - Init
    
    public init(requestExecutor: RequestExecutor, deserializer: Deserializer = JSONDeserializer(), plugins: [PluginType] = [ErrorPreprocessorPlugin(errorPreprocessor: NetworkErrorProcessor())]) {
        self.requestExecutor = requestExecutor
        self.deserializer = deserializer
        self.plugins = plugins
    }

    public func execute<T, U: ResponseParser>(request: APIRequest, parser: U) -> Task<T> where U.Representation == T {
        let taskProducer: RequestTaskProducer = {
            self.willSend(request: request)
            
            return self
                .requestExecutor
                .execute(request: self.prepare(request: request))
        }
        
        return _execute(taskProducer, parser: parser)
    }

    public func execute<T: SerializeableAPIRequest>(request: T) -> Task<T.Parser.Representation> {
        return execute(request: request, parser: request.parser)
    }

    // MARK: Multipart Request Execution

    public func execute<T, U: ResponseParser>(multipartRequest: APIRequest, parser: U) -> Task<T> where U.Representation == T {
        let taskProducer: RequestTaskProducer = {
            self.willSend(request: multipartRequest)
            
            return self
                .requestExecutor
                .execute(multipartRequest: self.prepare(request: multipartRequest))
        }
        
        return _execute(taskProducer, parser: parser)
    }
    
    public func execute<T: SerializeableAPIRequest>(multipartRequest: T) -> Task<T.Parser.Representation> {
        return execute(multipartRequest: multipartRequest, parser: multipartRequest.parser)
    }
    
}

private extension APIClient {
 
    typealias RequestTaskProducer = () -> Task<HTTPResponse>
    
    func validate(_ response: HTTPResponse) -> Task<HTTPResponse> {
        switch response.httpResponse.statusCode {
        case (200...299):
            return Task(response)
        
        default:
            return Task(error: self.process(response) ?? NetworkError.undefined)
        }
    }
    
    func _execute<T, U: ResponseParser>(_ requestTaskProducer: @escaping RequestTaskProducer, parser: U) -> Task<T> where U.Representation == T {
        let requestTask = requestTaskProducer()
        func validatedTask(from task: Task<HTTPResponse>) -> Task<HTTPResponse> {
            return task.continueWithTask { responseTask in
                if let response = responseTask.result {
                    self.didReceive(response)
                    
                    return self.validate(response)
                }
                
                return responseTask
            }
        }
        
        return validatedTask(from: requestTask)
            .continueOnErrorWithTask { error -> Task<HTTPResponse> in
                self.resolve(error).continueWithTask { task -> Task<HTTPResponse> in
                    if let result = task.result, result {
                        return validatedTask(from: requestTaskProducer())
                    } else {
                        return Task(error: error)
                    }
                }
            }
            .continueOnSuccessWith(responseExecutor, continuation: { response, data -> AnyObject in
                return try self.deserializer.deserialize(response, data: data)
            })
            .continueOnSuccessWith(responseExecutor, continuation: { response in
                return try parser.parse(response)
            })
            .continueOnSuccessWith { response in
                return self.process(result: response)
            }
    }
    

}

// MARK: - Plugins support

private extension APIClient {
    
    func process<T>(result: T) -> T {
        return plugins.reduce(result) { $0.1.process($0.0) }
    }
    
    func resolve(_ error: Error) -> Task<Bool> {
        let tasks: [Task<Bool>] = plugins.map { $0.resolve(error) }
        
        return Task.whenAllResult(tasks).continueWithTask { task -> Task<Bool> in
            if let array = task.result {
                return Task(!array.contains(false))
            }
            
            return Task(false)
        }
    }
    
    func didReceive(_ response: HTTPResponse) {
        plugins.forEach { $0.didReceive(response: response) }
    }
    
    func process(_ response: HTTPResponse) -> Error? {
        for plugin in plugins {
            if let error = plugin.processError(response) {
                return error
            }
        }
        
        return nil
    }
    
    func willSend(request: APIRequest) {
        plugins.forEach { $0.willSend(request)}
    }
    
    func prepare(request: APIRequest) -> APIRequest {
        return plugins.reduce(request) { $0.1.prepare($0.0) }
    }
    
}
