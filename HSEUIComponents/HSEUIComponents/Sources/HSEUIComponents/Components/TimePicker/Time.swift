import Foundation

public struct Time: Equatable, Comparable {
    
    public let hour: Int
    
    public let minute: Int
    
    public init(hour: Int, minute: Int) {
        self.hour = hour
        self.minute = minute
    }
    
    public init(from minutes: Int, withFormat: Bool = true) {
        if minutes < 0 {
            self.init(hour: 0, minute: 0)
        } else {
            let formattedMins = minutes % (60 * 24)
            self.init(hour: (withFormat ? formattedMins : minutes) / 60, minute: formattedMins % 60)
        }
    }
    
    public init?(from minutes: Int?) {
        if let minutes = minutes {
            self.init(from: minutes)
        } else {
            return nil
        }
    }
    
    public init(from date: Date) {
        hour = Calendar.current.component(.hour, from: date)
        minute = Calendar.current.component(.minute, from: date)
    }
    
    public init?(from stringValue: String) {
        let arr = stringValue.trimmingCharacters(in: .whitespaces).split(separator: ":")
        if arr.count == 2, let hour = Int(arr[0]), let minute = Int(arr[1]) {
            self.init(hour: hour, minute: minute)
        } else {
            return nil
        }
    }
    
    public static var midnight: Time {
        .init(hour: 0, minute: 0)
    }
    
    public func toMinutes() -> Int {
        hour * 60 + minute
    }
    
}

public extension Time {
    
    static func + (left: Time, right: Time) -> Time {
        .init(from: left.toMinutes() + right.toMinutes())
    }
    
    static func + (left: Time, right: Int) -> Time {
        .init(from: left.toMinutes() + right)
    }
    
    static func - (left: Time, right: Time) -> Time {
        .init(from: left.toMinutes() - right.toMinutes())
    }
    
    static func - (left: Time, right: Int) -> Time {
        .init(from: left.toMinutes() - right)
    }
    
    static func > (left: Time, right: Time) -> Bool {
        left.toMinutes() > right.toMinutes()
    }
    
    static func < (left: Time, right: Time) -> Bool {
        left.toMinutes() < right.toMinutes()
    }
    
}

public extension Time {
    
    func toDate(_ date: Date = Date()) -> Date? {
        Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: date)
    }
    
    func toNonOptionalDate(_ date: Date = Date()) -> Date {
        self.toDate(date) ?? Date()
    }
    
}

public extension Date {
    
    func toTime() -> Time {
        let hour = Calendar.current.component(.hour, from: self)
        let minute = Calendar.current.component(.minute, from: self)
        return Time(hour: hour, minute: minute)
    }
    
}
