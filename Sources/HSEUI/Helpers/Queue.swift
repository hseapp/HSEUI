import Foundation

public func mainQueue(delay: TimeInterval, block: @escaping Action) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        block()
    }
}

public func mainQueue(block: @escaping Action) {
    guard Thread.isMainThread else {
        return DispatchQueue.main.async(execute: block)
    }
    
    block()
}

public func backgroundQueue(delay: Double, block: @escaping Action) {
    DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
        block()
    }
}

public func backgroundQueue(block: @escaping Action) {
    backgroundQueue(delay: 0, block: block)
}
