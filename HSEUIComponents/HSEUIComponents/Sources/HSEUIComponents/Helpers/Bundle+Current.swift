import Foundation

extension Bundle {
    static var current: Bundle {
        class LocalClass {}
        return Bundle(for: LocalClass.self)
    }
}
