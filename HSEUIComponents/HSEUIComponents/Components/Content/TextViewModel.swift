import UIKit
import HSEUI

public class TextViewModel: CellViewModel {
    
    /**
     - **primary**: regular / 17
     - **compact**: regular / 14
     - **secondary**: regular / 14, secondary text color
     */
    public enum Style {
        case primary
        case compact
        case secondary
    }
    
    /**
     - **textView**: supports links highlight, but not does not support taps
     - **label**: support taps
     */
    public enum ViewType: Equatable {
        case textView
        case label
    }
    
    /// Text view with style
    /// - Parameters:
    ///   - text: text
    ///   - attributedText: attributed text
    ///   - style: `primary`: regular / 17; `compact`: regular / 14; `secondary`: regular / 14, secondary text color
    ///   - preferredViewType: if cell has `tapCallback` than `viewType` will be `label`, otherwise preffred type
    ///   - tapCallback: tap callback
    ///   - useChevron: chevron
    public init(
        text: String? = nil,
        attributedText: NSAttributedString? = nil,
        style: Style,
        preferredViewType: ViewType = .textView,
        alignment: NSTextAlignment = .left,
        tapCallback: Action? = nil,
        useChevron: Bool? = nil
    ) {
        if tapCallback != nil || preferredViewType == .label {
            super.init(view: LabelView.self, configureView: { view in
                view.update(for: style, text: text, attributedText: attributedText, isSelectable: tapCallback != nil, alignment: alignment)
            }, tapCallback: tapCallback, useChevron: useChevron)
        } else {
            super.init(view: TextView.self, configureView: { view in
                view.update(for: style, text: text, attributedText: attributedText, alignment: alignment)
            })
        }
    }
    
    /// Custom text view
    /// - Parameters:
    ///   - text: text
    ///   - attributedText: attributed text
    ///   - insets: text insets from border
    ///   - font: font
    ///   - textColor: text color
    ///   - prefferedViewType: if cell has `tapCallback` than `viewType` will be `label`, otherwise preffred type
    ///   - tapCallback: tap callback
    ///   - useChevron: chevron
    public init(
        text: String?,
        attributedText: NSAttributedString? = nil,
        insets: UIEdgeInsets = .init(top: 4, left: 16, bottom: 4, right: 16),
        font: UIFont = Font.main(weight: .regular).withSize(14),
        textColor: UIColor = Color.Base.label,
        preferredViewType: ViewType = .textView,
        alignment: NSTextAlignment = .left,
        tapCallback: Action? = nil,
        useChevron: Bool? = nil
    ) {
        if tapCallback != nil || preferredViewType == .label {
            super.init(view: LabelView.self, configureView: { view in
                view.update(text: text, attributedText: attributedText, insets: insets, font: font, textColor: textColor, isSelectable: tapCallback != nil, alignment: alignment)
            }, tapCallback: tapCallback, useChevron: useChevron)
        } else {
            super.init(view: TextView.self, configureView: { view in
                view.update(text: text, attributedText: attributedText, insets: insets, font: font, textColor: textColor, alignment: alignment)
            })
        }
    }
    
    public override func preferredWidth(for parentWidth: CGFloat) -> CGFloat? {
        return parentWidth
    }
    
}

open class TextView: CellView {

    public let textView: UITextView = {
        let textView = UITextView()
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.isSelectable = true
        textView.dataDetectorTypes = .link
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.tintColor = Color.Base.brandTint
        textView.textContainer.lineBreakMode = .byTruncatingTail
        textView.backgroundColor = .clear
        return textView
    }()
    
    public var textViewConstraints: AnchoredConstraints?

    open override func commonInit() {
        addSubview(textView)
        textViewConstraints = textView.stickToSuperviewEdges(.all)
    }
    
    open func update(
        for style: TextViewModel.Style,
        text: String?,
        attributedText: NSAttributedString?,
        alignment: NSTextAlignment
    ) {
        var insets: UIEdgeInsets
        var font: UIFont
        
        switch style {
        case .primary:
            insets = .init(top: 12, left: 16, bottom: 14, right: 12)
            font = Font.main(weight: .regular).withSize(17)
        case .compact, .secondary:
            insets = .init(top: 4, left: 16, bottom: 4, right: 12)
            font = Font.main(weight: .regular).withSize(14)
        }
        let textColor: UIColor = style == .secondary ? Color.Base.secondary : Color.Base.label
         
        update(text: text, attributedText: attributedText, insets: insets, font: font, textColor: textColor, alignment: alignment)
    }
    
    open func update(
        text: String?,
        attributedText: NSAttributedString?,
        insets: UIEdgeInsets,
        font: UIFont,
        textColor: UIColor,
        alignment: NSTextAlignment
    ) {
        if let text = text {
            textView.attributedText = nil
            textView.text = text
            textView.font = font
        } else if let attributedText = attributedText {
            textView.text = nil
            textView.font = nil
            textView.attributedText = attributedText
        }
        textView.textColor = textColor
        textView.textAlignment = alignment
        
        textViewConstraints?.updateInsets(insets)
    }
    
}

open class LabelView: CellView {
    
    public var isSelectable = false
    
    public let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    public var pasteBoardText: String?

    public var pasteBoardCompletion: Action?
    
    public var labelConstraints: AnchoredConstraints?
    
    open override func commonInit() {
        addSubview(label)
        labelConstraints = label.stickToSuperviewEdges(.all)
        heightAnchor.constraint(greaterThanOrEqualToConstant: 48).isActive = true
    }
    
    open override func setSelectedUI(selected: Bool) {
        if isSelectable {
            backgroundColor = selected ? Color.Base.selection : Color.Base.mainBackground
        }
    }
    
    open func update(
        for style: TextViewModel.Style,
        text: String?,
        attributedText: NSAttributedString?,
        isSelectable: Bool,
        alignment: NSTextAlignment
    ) {
        var insets: UIEdgeInsets
        var font: UIFont
        
        switch style {
        case .primary:
            insets = .init(top: 12, left: 16, bottom: 14, right: 12)
            font = Font.main(weight: .regular).withSize(17)
        case .compact, .secondary:
            insets = .init(top: 8, left: 16, bottom: 8, right: 12)
            font = Font.main(weight: .regular).withSize(14)
        }
        let textColor: UIColor = style == .secondary ? Color.Base.secondary : Color.Base.label
         
        update(text: text, attributedText: attributedText, insets: insets, font: font, textColor: textColor, isSelectable: isSelectable, alignment: alignment)
    }
    
    open func update(
        text: String?,
        attributedText: NSAttributedString?,
        insets: UIEdgeInsets,
        font: UIFont,
        textColor: UIColor,
        isSelectable: Bool,
        alignment: NSTextAlignment
    ) {
        self.isSelectable = isSelectable
        
        if let text = text {
            label.attributedText = nil
            label.text = text
        } else if let attributedText = attributedText {
            label.text = nil
            label.attributedText = attributedText
        }
        
        label.font = font
        label.textColor = textColor
        label.textAlignment = alignment
        
        labelConstraints?.updateInsets(insets)
        layoutIfNeeded()
    }
    
}

public extension String {
    
    var htmlAttributedString: NSAttributedString {
        let res = self.addingPaddings
        if let data = res.addingHTMLTemplate.data(using: .utf8), let attr = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil) {
            return attr.replacingBlackWithLabel
        }
        return NSAttributedString(string: res).replacingBlackWithLabel
    }
    
    private var addingHTMLTemplate: String {
            return """
    <!doctype html><html><head><style>
              body {
                font-family: -apple-system;
                font-size: 14px;
              }
              a {
                text-decoration:none;
                font-size: 14px;
                font-weight: 600;
              }
              p {
                display: block;
              }
              
            </style></head><body>\(self)</body></html>
    """
    }
    
    private var addingPaddings: String {
        let padding = "<p></p>"
        var result = self.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "</ul>", with: "</ul>\(padding)")
        if result.hasSuffix(padding) { result.removeLast(padding.count) }
        return result
    }
    
}

extension NSAttributedString {
    
    var replacingBlackWithLabel: NSAttributedString {
        let result = NSMutableAttributedString(attributedString: self)
        var allColors: [(color: UIColor, range: NSRange)] = []
        var i = 0
        while i < result.length {
            var range: NSRange = NSRange(location: i, length: 0)
            if let color = result.attribute(.foregroundColor, at: i, effectiveRange: &range) as? UIColor {
                i = range.location + range.length
                var red: CGFloat = 0
                var green: CGFloat = 0
                var blue: CGFloat = 0
                color.getRed(&red, green: &green, blue: &blue, alpha: nil)
                if red == 0 && green == 0 && blue == 0 {
                    allColors.append((color: UIColor.label, range: range))
                } else {
                    allColors.append((color: color, range: range))
                }
            } else {
                i += 1
            }
        }
        allColors.forEach {
            result.addAttribute(.foregroundColor, value: $0, range: $1)
        }
        return result
    }
    
}
