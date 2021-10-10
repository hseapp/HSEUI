import UIKit
import HSEUI

public extension UILabel {
    
    func setAttributedText(
        _ text: String?,
        kern: CGFloat? = nil,
        lineSpacing: CGFloat? = nil
    ) {
        var attributes: [NSAttributedString.Key : Any] = [
            .font: font ?? Font.main,
            .foregroundColor: textColor ?? Color.Base.label,
            
        ]
        
        if let kern = kern {
            attributes[.kern] = kern
        }
        
        let style: NSMutableParagraphStyle = .init()
        style.alignment = textAlignment
        if let lineSpacing = lineSpacing {
            style.lineSpacing = lineSpacing
        }
        attributes[.paragraphStyle] = style
        
        attributedText = NSAttributedString(string: text ?? "", attributes: attributes)
    }
    
}
