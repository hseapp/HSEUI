import HSEUI
import UIKit

open class DoubleTextViewModel: CellViewModel {
    
    /**
     - **primary**: both regular / 16
     - **compact**: both regular / 14
     subtitle color always `secondaryLabel`
     */
    public enum Style {
        case primary
        case compact
    }
    
    /// Double text view
    ///
    /// If you do not need subtitle, use `TextViewModel` instead
    /// - Parameters:
    ///   - title: main text
    ///   - subtitle: secondary text
    ///   - style: `primary`: both regular / 16; `compact`: both regular / 14
    ///   - tapCallback: tapCallback
    convenience public init(
        title: String,
        subtitle: String,
        style: Style,
        tapCallback: Action? = nil
    ) {
        let subtitleColor: UIColor = Color.Base.secondary
        let titleColor: UIColor = Color.Base.label
        var titleFont: UIFont
        var subtitleFont: UIFont
        var insets: UIEdgeInsets

        switch style {
        case .primary:
            titleFont = Font.main(weight: .regular).withSize(16)
            subtitleFont = Font.main(weight: .regular).withSize(16)
            insets = UIEdgeInsets(top: 14.33, left: 16, bottom: 14.33, right: 16)
        case .compact:
            titleFont = Font.main(weight: .regular).withSize(14)
            subtitleFont = Font.main(weight: .regular).withSize(14)
            insets = UIEdgeInsets(top: 10.5, left: 16, bottom: 10.5, right: 16)
        }
        
        self.init(title: title, subtitle: subtitle, titleColor: titleColor, subtitleColor: subtitleColor, titleFont: titleFont, subtitleFont: subtitleFont, insets: insets, tapCallback: tapCallback)
    }
    
    /// Double text view
    ///
    /// If you do not need subtitle, use `TextViewModel` instead
    /// - Parameters:
    ///   - title: main text
    ///   - subtitle: secondary text
    ///   - subtitleColor: subtitle color
    ///   - titleFont: title font
    ///   - subtitleFont: subtitle font
    ///   - tapCallback: tap callback
    public init(
        title: String,
        subtitle: String,
        titleColor: UIColor = Color.Base.label,
        subtitleColor: UIColor = Color.Base.label,
        titleFont: UIFont = Font.main(weight: .regular).withSize(14),
        subtitleFont: UIFont = Font.main(weight: .regular).withSize(14),
        insets: UIEdgeInsets = .init(top: 10, left: 16, bottom: 10, right: 16),
        tapCallback: Action? = nil,
        useChevron: Bool? = nil
    ) {
        super.init(view: DoubleTextView.self, configureView: { view in
            view.update(text: title, subtext: subtitle, titleColor: titleColor, subtitleColor: subtitleColor, titleFont: titleFont, subtitleFont: subtitleFont, insets: insets)
            view.isSelectable = tapCallback != nil
        }, tapCallback: tapCallback, useChevron: useChevron)
    }
    
}

open class DoubleTextView: CellView {
    
    public let mainLabel: UILabel = {
        let label = UILabel()
        label.font = Font.main(weight: .regular).withSize(14)
        label.textAlignment = .left
        return label
    }()
    
    public let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = Font.main(weight: .regular).withSize(14)
        return label
    }()
    
    public lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [mainLabel, subtitleLabel])
        stack.distribution = .fill
        stack.axis = .horizontal
        stack.alignment = .fill
        return stack
    }()
    
    public var stackConstraints: AnchoredConstraints?
    
    public var isSelectable: Bool = false
    
    open override func setSelectedUI(selected: Bool) {
        if isSelectable {
            backgroundColor = selected ? Color.Base.selection : Color.Base.mainBackground
        }
    }
    
    open override func commonInit() {
        addSubview(stack)
        stackConstraints = stack.stickToSuperviewEdges(.all, insets: .init(top: 10, left: 16, bottom: 10, right: 16))
    }
    
    public func update(
        text: String,
        subtext: String,
        titleColor: UIColor,
        subtitleColor: UIColor,
        titleFont: UIFont,
        subtitleFont: UIFont,
        insets: UIEdgeInsets
    ) {
        mainLabel.text = text
        subtitleLabel.text = subtext
        mainLabel.font = titleFont
        subtitleLabel.font = subtitleFont
        mainLabel.textColor = titleColor
        subtitleLabel.textColor = subtitleColor
        
        stackConstraints?.updateInsets(insets)
    }
    
}
