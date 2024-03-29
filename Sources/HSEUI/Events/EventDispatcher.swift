import UIKit

private class EventDispatcher {

    static let main = EventDispatcher()

    private var subscriptions: [Event: [Int: Any]] = [:]

    func add(listener: EventListener) {
        listener.nonce = Nonce()
        if subscriptions[listener.event] == nil {
            subscriptions[listener.event] = [listener.nonce: listener.callback]
        }
        else {
            subscriptions[listener.event]![listener.nonce] = listener.callback
        }
    }

    func remove(listener: EventListener) {
        subscriptions[listener.event]?.removeValue(forKey: listener.nonce)
    }

    func raise<T>(event: Event, data: T) {
        subscriptions[event]?.values.forEach { callback in
            (callback as? (T) -> Void)?(data)
        }
    }

    func raise(event: Event) {
        subscriptions[event]?.values.forEach { callback in
            (callback as? Action)?()
        }
    }

}

public enum Event: Hashable {
    
    case withId(Int)
    case other(String)

    public static func new() -> Event {
        return Event.withId(Nonce())
    }
    
}

extension Event {

    public func raise<T>(data: T) {
        mainQueue {
            EventDispatcher.main.raise(event: self, data: data)
        }
    }

    public func raise() {
        mainQueue {
            EventDispatcher.main.raise(event: self)
        }
    }

    public func listen<T>(callback: @escaping (T) -> Void) -> EventListener {
        let listener = EventListener(event: self, callback: callback)
        EventDispatcher.main.add(listener: listener)
        return listener
    }

    public func listen(callback: @escaping Action) -> EventListener {
        let listener = EventListener(event: self, callback: callback)
        EventDispatcher.main.add(listener: listener)
        return listener
    }

}

public class EventListener: Equatable {

    fileprivate var nonce: Int = 0
    fileprivate var callback: Any
    fileprivate var event: Event

    init(event: Event, callback: Any) {
        self.event = event
        self.callback = callback
    }

    deinit {
        EventDispatcher.main.remove(listener: self)
    }

    public static func == (lhs: EventListener, rhs: EventListener) -> Bool {
        return lhs.nonce == rhs.nonce
    }

}
