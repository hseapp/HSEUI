import UIKit

public func sfSymbol(_ name: String, tintColor: UIColor? = nil) -> UIImage? {
    return UIImage(systemName: name)?.withTintColor(tintColor ?? Color.Base.image, renderingMode: .alwaysOriginal)
}
