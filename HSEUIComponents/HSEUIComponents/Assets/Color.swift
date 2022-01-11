import UIKit
import HSEUI

#if SWIFT_PACKAGE
   let resourceBundle = Bundle.module
#else
private extension Bundle {
    
    static var _module: Bundle {
        class T {}
        return Bundle(for: T.self)
    }
    
}
let resourceBundle = Bundle._module
#endif

public extension Color {
    
    class TimePicker {
        public static let separator = UIColor(named: "timePickerSeparator", in: resourceBundle, compatibleWith: UITraitCollection.current)!
        
        public static let green = UIColor(named: "green", in: resourceBundle, compatibleWith: UITraitCollection.current)!
        
        public static let red = UIColor(named: "red", in: resourceBundle, compatibleWith: UITraitCollection.current)!

        public static let thumb = Color.Base.selection

        public static let schedule = Color.Base.selection.withAlphaComponent(0.5)
    }
    
}

