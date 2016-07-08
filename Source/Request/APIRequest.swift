
import Foundation

public enum APIRequestMethod: UInt {
    
    case GET, POST, PUT, DELETE
}

public protocol APIRequest {
    
    var path: String { get }
    var parameters: [String: AnyObject]? { get }
    var method: APIRequestMethod { get }
    var scopes: [String]? { get }
    var headers: [String: String]? { get }
    var multipartFormData: (MultipartFormDataType -> Void)? { get }
    
}

public protocol MultipartFormDataType {
    
    var contentType: String { get }
    var contentLength: UInt64 { get }
    var boundary: String { get }
    
    func appendBodyPart(data data: NSData, name: String)
    func appendBodyPart(data data: NSData, name: String, mimeType: String)
    func appendBodyPart(data data: NSData, name: String, fileName: String, mimeType: String)
    func appendBodyPart(fileURL fileURL: NSURL, name: String)
    func appendBodyPart(fileURL fileURL: NSURL, name: String, fileName: String, mimeType: String)
    func appendBodyPart(stream stream: NSInputStream, length: UInt64, name: String, fileName: String, mimeType: String)
    func appendBodyPart(stream stream: NSInputStream, length: UInt64, headers: [String : String])
    
}

struct RequestAdapter: APIRequest {
    
    var path: String
    var parameters: [String: AnyObject]?
    var method: APIRequestMethod
    var scopes: [String]?
    var headers: [String: String]?
    var multipartFormData: (MultipartFormDataType -> Void)?
    
    init(headers: [String: String], request: APIRequest) {
        self.path = request.path
        self.parameters = request.parameters
        self.method = request.method
        self.scopes = request.scopes
        self.multipartFormData = request.multipartFormData
        if let requestHeaders = request.headers {
            var decoratedHeader = requestHeaders
            headers.forEach { key, value in
                decoratedHeader[key] = value
            }
            self.headers = decoratedHeader
        } else {
            self.headers = headers
        }
    }
    
}

public protocol SerializeableAPIRequest: APIRequest {
    
    associatedtype Parser: ResponseParser

    var parser: Parser { get }
    
}

extension APIRequest {

    var method: APIRequestMethod {
        return .GET
    }
    
    var parameters: [String: AnyObject]? {
        return nil
    }

    var scopes: [String]? {
        return nil
    }

}
