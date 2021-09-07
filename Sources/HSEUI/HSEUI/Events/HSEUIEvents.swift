import UIKit

public enum KeyboardEvent {
    public static let keyboardWillShow = Event.new()
    public static let keyboardDidShow = Event.new()
    public static let keyboardWillHide = Event.new()
    public static let keyboardDidHide = Event.new()
}

public enum DeviceEvent {
    public static let orientationDidChange = Event.new()
}
