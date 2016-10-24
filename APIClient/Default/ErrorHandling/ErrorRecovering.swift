import Foundation
import BoltsSwift

public protocol ErrorRecovering {
    
    func canRecover(from error: Error) -> Bool
    func recover(from error: Error) -> Task<Bool>
    
}
