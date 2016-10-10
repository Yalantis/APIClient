import Foundation
//import OHHTTPStubs
import BoltsSwift

class StubbedAlamofireRequestExecutor: AlamofireRequestExecutor {
    
    struct Execution {
        
        var request: APIRequest
        
        init(request: APIRequest) {
            self.request = request
        }
        
    }
    
    private(set) var executionStack: [Execution] = []
    
    override func execute(request: APIRequest) -> Task<APIClient.HTTPResponse> {
//        executionStack.append(Execution(request: request))
//        let _ = stub(isHost("ror-tpl.herokuapp.com")) { _ in
//            let pathString = request.path.replacingOccurrences(of: "/", with: "_").lowercased()
//            let methodString = "_" + "\(request.method)".lowercased()
//            guard let path = OHPathForFile(pathString + methodString + ".json", self.dynamicType) else {
//                preconditionFailure("Could not load file")
//            }
//            
//            return OHHTTPStubsResponse(fileAtPath: path, statusCode: 200, headers: [ "Content-Type": "application/json" ])
//
//        }
        
        return super.execute(request: request)
    }
    
}
