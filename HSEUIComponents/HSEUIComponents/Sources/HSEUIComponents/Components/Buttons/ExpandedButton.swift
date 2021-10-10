import UIKit

open class ExpandedButton: UIButton {
    
    public weak var parent: UIView?
    
    public let offset: CGFloat = 5
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let parent = parent ?? superview else { return super.point(inside: point, with: event) }
        let newBounds: CGRect = .init(x: -offset, y: -offset, width: bounds.width + 2 * offset, height: parent.bounds.height + 2 * offset)
        return newBounds.contains(point)
    }
    
}
