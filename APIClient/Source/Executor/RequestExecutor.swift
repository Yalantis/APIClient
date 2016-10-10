import Foundation
import BoltsSwift

public protocol RequestExecutor {
    
    func execute(request: APIRequest) -> Task<APIClient.HTTPResponse>
    func execute(multipartRequest: APIRequest) -> Task<APIClient.HTTPResponse>
    
}
