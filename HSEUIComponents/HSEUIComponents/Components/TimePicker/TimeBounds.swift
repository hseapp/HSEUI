import Foundation

public struct TimeBounds: Equatable {
    
    public var start: Time
    
    public var end: Time
    
    public init(start: Time, end: Time) {
        self.start = start
        self.end = end
    }
    
    public static var day: TimeBounds {
        .init(start: .init(hour: 0, minute: 0), end: .init(hour: 23, minute: 59))
    }
    
    public static var workHours: TimeBounds {
        .init(
            start: .init(hour: 9, minute: 0),
            end: .init(hour: 23, minute: 0)
        )
    }
    
    public func intersect(_ other: TimeBounds) -> Bool {
        !(start >= other.end || end <= other.start)
    }
    
}
