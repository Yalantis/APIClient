import Foundation
import UIKit.UIImage
import BoltsSwift
import Alamofire

public class APIClient: NSObject {
    
    public typealias HTTPResponse = (NSHTTPURLResponse, NSData)
    
    private let responseExecutor: Executor = .Queue(dispatch_queue_create(NSBundle.mainBundle().bundleIdentifier!, DISPATCH_QUEUE_CONCURRENT))
    private let requestExecutor: RequestExecutor
    private let deserializer: Deserializer
    private let errorProcessor: APIErrorProcessing = APIErrorProcessor()
    private var credentialsProducer: CredentialsProducing?

    // MARK: - Init
    
    public init(requestExecutor: RequestExecutor, deserializer: Deserializer = JSONDeserializer(), credentialsProducer: CredentialsProducing? = nil) {
        self.requestExecutor = requestExecutor
        self.deserializer = deserializer
        self.credentialsProducer = credentialsProducer
    }
    
    // MARK: - Request
    
    private func validateResponse(response: HTTPResponse) -> Task<HTTPResponse> {
        switch response.0.statusCode {
        case (200...299):
            return Task<HTTPResponse>(response)
        default:
            return Task<HTTPResponse>(error: errorProcessor.processErrorWithResponse(response))
        }
    }
    
    private func decoratedRequest(request: APIRequest) -> APIRequest {
        let decoratedRequest: APIRequest
        if let credentialsProducer = credentialsProducer {
            decoratedRequest = RequestAdapter(
                headers: ["Authorization": "Token token=\(credentialsProducer.token)"],
                request: request
            )
        } else {
            decoratedRequest = request
        }
        
        return decoratedRequest
    }
    
    private static var recoverableErrors: Set<APIError> {
        return Set<APIError>([.BadToken, .ResourceUnauthorizedClient])
    }
    
    private func canRecoverFromError(error: APIError) -> Bool {
        return self.dynamicType.recoverableErrors.contains(error)
    }
    
    private func _executeRequest<T, U: ResponseParser where U.Representation == T>(requestTaskProducer: Void -> Task<HTTPResponse>, parser: U) -> Task<T> {
        let deserializer = self.deserializer
        
        let requestTask = requestTaskProducer()
        func validatedTaskFromTask(task: Task<HTTPResponse>) -> Task<HTTPResponse> {
            return task.continueWithTask(continuation: { responseTask in
                if let response = responseTask.result {
                    return self.validateResponse(response)
                }
                
                return responseTask
            })
        }
        
        return validatedTaskFromTask(requestTask).continueWithTask(continuation: { (validatedTask: Task<HTTPResponse>) -> Task<HTTPResponse> in
            if let error = validatedTask.error as? APIError, let credentialsProducer = self.credentialsProducer where self.canRecoverFromError(error) {
                
                return credentialsProducer.restoreCredentials().continueWithTask { task -> Task<HTTPResponse> in
                    if let result = task.result where result {
                        return validatedTaskFromTask(requestTaskProducer())
                    } else {
                        return Task(error: error)
                    }
                }
            }
            
            return validatedTask
        }).continueOnSuccessWith(responseExecutor, continuation: { response, data -> AnyObject in
            return try deserializer.deserialize(response, data: data)
        }).continueOnSuccessWith(responseExecutor, continuation: { response in
            return try parser.parse(response)
        }).continueOnSuccessWith(.MainThread, continuation: { response in
            return response
        })
    }
    
    // MARK: Request Execution
    
    public func executeRequest<T, U: ResponseParser where U.Representation == T>(request: APIRequest, parser: U) -> Task<T> {
        return _executeRequest({
                return self.requestExecutor.executeRequest(self.decoratedRequest(request))
            },
            parser: parser
        )
    }
    
    
    public func executeRequest<T: SerializeableAPIRequest>(request: T) -> Task<T.Parser.Representation> {
        return executeRequest(request, parser: request.parser)
    }
    
    // MARK: Multipart Request Execution
    
    public func executeMultipartRequest<T, U: ResponseParser where U.Representation == T>(request: APIRequest, parser: U) -> Task<T> {
        return _executeRequest({
                self.requestExecutor.executeMultipartRequest(self.decoratedRequest(request))
            },
            parser: parser
        )
    }
    
    public func executeMultipartRequest<T: SerializeableAPIRequest>(request: T) -> Task<T.Parser.Representation> {
        return executeMultipartRequest(request, parser: request.parser)
    }
    
}

