import Foundation
import BoltsSwift

public protocol CredentialsProducing {
    
    var token: String { get }
    
    func restoreCredentials() -> Task<Bool>
    
}
