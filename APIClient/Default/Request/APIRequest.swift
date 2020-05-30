import Foundation

public typealias ProgressHandler = (Progress) -> ()

public enum APIRequestEncoding {
    
    case json, url
}

public enum APIRequestMethod: String {
    
    case options, get, head, post, put, patch, delete, trace, connect
}

public protocol APIRequest {
    
    var path: String { get }
    var method: APIRequestMethod { get }
    var encoding: APIRequestEncoding { get }
    var parameters: [String: Any]? { get }
    var headers: [String: String]? { get }
}

public extension APIRequest {

    var method: APIRequestMethod { return .get }
    var parameters: [String: Any]? { return nil }
    var encoding: APIRequestEncoding { return .url }
    var headers: [String: String]? { return nil }
}

public protocol DownloadAPIRequest: APIRequest {
    
    var progressHandler: ProgressHandler? { get }
}

public protocol MultipartAPIRequest: DownloadAPIRequest {
    
    var multipartFormData: ((MultipartFormDataType) -> Void) { get }
}

public protocol MultipartFormDataType {
    
    var contentType: String { get }
    var contentLength: UInt64 { get }
    var boundary: String { get }
    
    func append(_ data: Data, withName name: String, fileName: String?, mimeType: String?)
    func append(_ fileURL: URL, withName name: String)
    func append(_ fileURL: URL, withName name: String, fileName: String, mimeType: String)
    func append(_ stream: InputStream, withLength length: UInt64, name: String, fileName: String, mimeType: String)
    func append(_ stream: InputStream, withLength length: UInt64, headers: [String: String])
}
