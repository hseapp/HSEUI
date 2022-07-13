import UIKit

protocol ParentBoundsWidthCatcher {
    func catchParentBounds(width: CGFloat)
}

extension UIView {

    func throwWidth(_ width: CGFloat) {
        if width == 0 { return }
        subviews.forEach { view in
            if let catcher = view as? ParentBoundsWidthCatcher {
                catcher.catchParentBounds(width: width)
            } else {
                view.throwWidth(width)
            }
        }
    }
}
