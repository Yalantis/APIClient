import Foundation
import BoltsSwift

open class APIClient: NSObject, NetworkClient {
    
    public typealias HTTPResponse = (HTTPURLResponse, Data)
    
    fileprivate let responseExecutor: Executor = .queue(DispatchQueue(label: Bundle.main.bundleIdentifier!, attributes: .concurrent))
    fileprivate let requestExecutor: RequestExecutor
    fileprivate let deserializer: Deserializer
    fileprivate let plugins: [PluginType]
    // todo: replace with plugin
    fileprivate let errorProcessor: APIErrorProcessing
    // todo: replace with plugin
    fileprivate let errorRecoverer: ErrorRecovering?
    // todo: replace with plugin
    fileprivate let requestDecorator: RequestDecorator?
    
    // MARK: - Init
    
    public init(requestExecutor: RequestExecutor, deserializer: Deserializer = JSONDeserializer(), errorRecoverer: ErrorRecovering? = nil, errorProcessor: APIErrorProcessing = APIErrorProcessor(), requestDecorator: RequestDecorator? = nil, plugins: [PluginType] = []) {
        self.requestExecutor = requestExecutor
        self.deserializer = deserializer
        self.errorRecoverer = errorRecoverer
        self.errorProcessor = errorProcessor
        self.requestDecorator = requestDecorator
        self.plugins = plugins
    }

    public func execute<T, U: ResponseParser>(request: APIRequest, parser: U) -> Task<T> where U.Representation == T {
        let taskProducer: RequestTaskProducer = {
            self.willSend(request: request)
            
            return self
                .requestExecutor
                .execute(request: self.decoratedRequest(from: self.prepare(request: request)))
        }
        
        return _execute(taskProducer,parser: parser)
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
                .execute(multipartRequest: self.decoratedRequest(from: self.prepare(request: multipartRequest)))
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
        switch response.0.statusCode {
        case (200...299):
            return Task<HTTPResponse>(response)
        default:
            return Task<HTTPResponse>(error: errorProcessor.processError(using: response))
        }
    }
    
    func decoratedRequest(from request: APIRequest) -> APIRequest {
        let decoratedRequest: APIRequest
        if let requestDecorator = requestDecorator {
            decoratedRequest = requestDecorator.decoratedRequest(from: request)
        } else {
            decoratedRequest = request
        }
        
        return decoratedRequest
    }
    
    func _execute<T, U: ResponseParser>(_ requestTaskProducer: @escaping RequestTaskProducer, parser: U) -> Task<T> where U.Representation == T {
        let requestTask = requestTaskProducer()
        func validatedTask(from task: Task<HTTPResponse>) -> Task<HTTPResponse> {
            return task.continueWithTask { responseTask in
                if let response = responseTask.result {
                    return self.validate(response)
                }
                
                return responseTask
            }
        }
        
        return validatedTask(from: requestTask)
            .continueOnErrorWithTask { error -> Task<HTTPResponse> in
                self.resolve(error).continueWithTask { result -> Task<HTTPResponse> in
                    if let errorRecoverer = self.errorRecoverer, errorRecoverer.canRecover(from: error) {
                        return errorRecoverer.recover(from: error).continueWithTask { task -> Task<HTTPResponse> in
                            if let result = task.result, result {
                                return validatedTask(from: requestTaskProducer())
                            } else {
                                return Task(error: error)
                            }
                        }
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
            .continueOnErrorWithTask { error in
                return Task(error: self.wrap(error))
            }
    }
    

}

// MARK: - Plugins support

private extension APIClient {
    
    func process<T>(result: T) -> T {
        return plugins.reduce(result) { $0.1.process($0.0) }
    }
    
    func resolve(_ error: Error) -> Task<Bool> {
        var tasks: [Task<Bool>] = []
        for plugin in plugins {
            tasks.append(plugin.resolve(error))
        }
        
        return Task.whenAllResult(tasks).continueWithTask { task -> Task<Bool> in
            if let array = task.result {
                return Task(!array.contains(false))
            }
            
            return Task(false)
        }
    }
    
    func wrap(_ error: Error) -> Error {
        return plugins.reduce(error) { $0.1.wrap($0.0) }
    }
    
    func willSend(request: APIRequest) {
        plugins.forEach { $0.willSend(request)}
    }
    
    func prepare(request: APIRequest) -> APIRequest {
        return plugins.reduce(request) { $0.1.prepare($0.0) }
    }
    
}
