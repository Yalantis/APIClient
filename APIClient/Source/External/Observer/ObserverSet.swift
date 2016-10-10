import Foundation

final class ObserverInfo<T>: Hashable {
	
	fileprivate let observer: (T) -> Void
	
	fileprivate init(observer: @escaping (T) -> Void) {
		self.observer = observer
	}
	
	var hashValue: Int { return Unmanaged.passUnretained(self).toOpaque().hashValue }
    
}

func == <T>(lhs: ObserverInfo<T>, rhs: ObserverInfo<T>) -> Bool {
	return lhs.hashValue == rhs.hashValue
}

public class ObserverSet<T> {
	
	private var lock: OSSpinLock = OS_SPINLOCK_INIT
	private var descriptors: Set<ObserverInfo<T>> = []
	
	public var notificationQueue: DispatchQueue?
	
	public init() {}
	
	public func add(_ observer: @escaping (T) -> Void) -> Disposable {
        let descriptor = ObserverInfo(observer: observer)
		
		OSSpinLockLock(&lock)
		descriptors.insert(descriptor)
		OSSpinLockUnlock(&lock)
		
		let disposable = Disposable { [weak self, weak descriptor] in
			if let _self = self, let descriptor = descriptor {
				OSSpinLockLock(&_self.lock)
				_self.descriptors.remove(descriptor)
				OSSpinLockUnlock(&_self.lock)
			}
		}
		
		return disposable
	}
	
	public func send(_ value: T) {
		OSSpinLockLock(&lock)
		let usedDescriptors = descriptors
		OSSpinLockUnlock(&lock)
		
		if let queue = notificationQueue {
            queue.async(execute: { 
                    for descriptor in usedDescriptors {
                        descriptor.observer(value)
                    }
                }
            )
		} else {			
			for descriptor in usedDescriptors {
				descriptor.observer(value)
			}
		}
	}
	
	public func disposeAll() {
		OSSpinLockLock(&lock)
		descriptors.removeAll()
		OSSpinLockUnlock(&lock)
	}
}
