import Foundation

public protocol ErrorRecovering {
    
    func canRecover(from error: Error) -> Bool
    func recover(from error: Error) -> Bool
    
}
