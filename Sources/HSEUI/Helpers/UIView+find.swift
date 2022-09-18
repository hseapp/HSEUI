import UIKit

extension UIView {
    
    public func findSuperview<T: UIView>(_ type: T.Type) -> T? {
        if let c = self as? T {
            return c
        }
        else {
            return superview?.findSuperview(type)
        }
    }
    
    public func findChildren<T: UIView>(_ type: T.Type) -> [T] {
        var children: [T] = []
        
        if let c = self as? T {
            children.append(c)
        }
        else {
            subviews.forEach({ children.append(contentsOf: $0.findChildren(type)) })
        }
        
        return children
    }
    
}
