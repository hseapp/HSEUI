import UIKit
import HSEUI

public typealias HeaderViewButton = (title: String, action: Action?)

public class HeaderViewModel: CellViewModel {
    
    /**
     - **primary**: semibold / 17
     - **secondary**: semibold / 13
     - **large**: semibold / 20
     - **form**: regular / 14
     */
    public enum Style {
        case primary
        case secondary
        case large
        case form
    }
    
    /// Header view model with style
    /// - Parameters:
    ///   - text: header text
    ///   - attributedText: header attributed text, will be used if `text` == nil
    ///   - style: `primary`: semibold / 17;  `secondary`: semibold / 13; `large`: semibold / 20; `form`: regular / 14
    ///   - button: title button
    public init(
        text: String?,
        attributedText: NSAttributedString? = nil,
        style: Style = .secondary,
        button: (title: String, action: Action?)? = nil
    ) {
        super.init(view: HeaderView.self) { view in
            view.update(for: style, titleText: text, attributedTitleText: attributedText, buttonText: button?.title, buttonAction: button?.action)
        }
        self.voiceOver.accessibilityTraits = .header
    }
    
    /// Custom header view model
    /// - Parameters:
    ///   - text: header text
    ///   - attributedText: header attributed text, will be used if `text` == nil
    ///   - titleFont: title font
    ///   - titleColor: title color
    ///   - button: button title and action
    ///   - buttonFont: button font
    ///   - labelInsets: title insets from top, left and button
    ///   - buttonInsets: button insets from top and right
    public init(
        text: String?,
        attributedText: NSAttributedString? = nil,
        titleFont: UIFont,
        titleColor: UIColor,
        button: HeaderViewButton?,
        buttonFont: UIFont?,
        labelInsets: UIEdgeInsets,
        buttonInsets: UIEdgeInsets
    ) {
        super.init(view: HeaderView.self) { view in
            view.update(titleText: text, attributedTitleText: attributedText, titleFont: titleFont, titleColor: titleColor, buttonText: button?.title, buttonFont: buttonFont, labelInsets: labelInsets, buttonInsets: buttonInsets, buttonAction: button?.action)
        }
    }
    
}

open class HeaderView: CellView {
    
    public var action: Action? {
        didSet {
            button.accessibilityElementsHidden = action == nil
        }
    }

    public var labelConstraints: AnchoredConstraints?
    
    public var buttonConstraints: AnchoredConstraints?

    public let label: UILabel = {
        let label = UILabel()
        label.font = Font.main(weight: .semibold).withSize(17)
        label.numberOfLines = 0
        return label
    }()

    public lazy var button: ExpandedButton = {
        let button = ExpandedButton()
        button.parent = self
        button.setTitleColor(Color.Base.brandTint, for: .normal)
        button.setTitleColor(Color.Base.brandTint.withAlphaComponent(0.5), for: .highlighted)
        button.addTarget(self, action: #selector(handleButton), for: .touchUpInside)
        button.titleLabel?.font = Font.main(weight: .regular).withSize(15)
        button.contentHorizontalAlignment = .trailing
        button.contentVerticalAlignment = .top
        button.contentEdgeInsets = .init(top: .leastNonzeroMagnitude, left: .leastNonzeroMagnitude, bottom: .leastNonzeroMagnitude, right: .leastNonzeroMagnitude)
        return button
    }()

    open override func commonInit() {
        addSubview(button)
        buttonConstraints = button.stickToSuperviewEdges([.top, .right], insets: .init(top: 14, left: 0, bottom: 0, right: 16))
        button.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

        addSubview(label)
        labelConstraints = label.stickToSuperviewEdges([.left, .top, .bottom], insets: UIEdgeInsets(top: 12, left: 16, bottom: 10, right: 0))
        labelConstraints?.trailing = label.trailing(5, to: button)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    @objc private func handleButton() {
        action?()
    }
    
    open func update(
        for style: HeaderViewModel.Style,
        titleText: String?,
        attributedTitleText: NSAttributedString?,
        buttonText: String?,
        buttonAction: Action?
    ) {
        var titleFont: UIFont
        var buttonFont: UIFont
        var labelInsets: UIEdgeInsets
        var buttonInsets: UIEdgeInsets
        var titleColor: UIColor
        
        switch style {
        case .large:
            titleFont = Font.main(weight: .semibold).withSize(20)
            buttonFont = Font.main(weight: .regular).withSize(17)
            labelInsets = .init(top: 10, left: 16, bottom: 10, right: 0)
            buttonInsets = .init(top: 12, left: 0, bottom: 0, right: 16)
            titleColor = Color.Base.label
        case .primary:
            titleFont = Font.main(weight: .semibold).withSize(17)
            buttonFont = Font.main(weight: .regular).withSize(15)
            labelInsets = .init(top: 12, left: 16, bottom: 10, right: 0)
            buttonInsets = .init(top: 14, left: 0, bottom: 0, right: 16)
            titleColor = Color.Base.label
        case .secondary:
            titleFont = Font.main(weight: .semibold).withSize(13)
            buttonFont = Font.main(weight: .regular).withSize(15)
            labelInsets = .init(top: 14, left: 16, bottom: 10, right: 0)
            buttonInsets = .init(top: 12, left: 0, bottom: 0, right: 16)
            titleColor = Color.Base.secondary
        case .form:
            titleFont = Font.main(weight: .regular).withSize(14)
            buttonFont = Font.main(weight: .regular).withSize(15)
            labelInsets = .init(top: 8, left: 12, bottom: 0, right: 0)
            buttonInsets = .init(top: 8, left: 0, bottom: 0, right: 12)
            titleColor = Color.Base.secondary
        }
        
        update(titleText: style == .secondary ? titleText?.uppercased() : titleText, attributedTitleText: attributedTitleText, titleFont: titleFont, titleColor: titleColor, buttonText: buttonText, buttonFont: buttonFont, labelInsets: labelInsets, buttonInsets: buttonInsets, buttonAction: buttonAction)
    }
    
    open func update(
        titleText: String?,
        attributedTitleText: NSAttributedString?,
        titleFont: UIFont,
        titleColor: UIColor,
        buttonText: String?,
        buttonFont: UIFont?,
        labelInsets: UIEdgeInsets,
        buttonInsets: UIEdgeInsets,
        buttonAction: Action?
    ) {
        if let text = titleText {
            label.attributedText = nil
            label.text = text
        } else if let attributedText = attributedTitleText {
            label.text = nil
            label.attributedText = attributedText
        }
        label.font = titleFont
        label.textColor = titleColor
        button.setTitle(buttonText, for: .normal)
        button.titleLabel?.font = buttonFont
        
        labelConstraints?.top?.constant = labelInsets.top
        labelConstraints?.bottom?.constant = -labelInsets.bottom
        labelConstraints?.leading?.constant = labelInsets.left

        buttonConstraints?.top?.constant = buttonInsets.top
        buttonConstraints?.trailing?.constant = -buttonInsets.right
        
        action = buttonAction
        
        layoutIfNeeded()
    }
    
}

