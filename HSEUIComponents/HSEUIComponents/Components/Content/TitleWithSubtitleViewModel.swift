import UIKit
import HSEUI

public class TitleWithSubtitleViewModel: CellViewModel {

    public init(
        title: String,
        text: String?,
        numberOfTitleLines: Int = 0,
        allowSelection: Bool = false,
        attributedText: NSAttributedString? = nil,
        insets: UIEdgeInsets = .init(top: 11, left: 16, bottom: 13, right: 11),
        spacing: CGFloat = 2,
        deleteAction: Action? = nil,
        tapCallback: Action? = nil,
        useChevron: Bool = false,
        pasteBoardText: String? = nil,
        pasteBoardCompletion: Action? = nil
    ) {
        super.init(view: TitleWithSubtitleView.self, configureView: { view in
            view.update(title: title, text: text, attributedText: attributedText, numberOfTitleLines: numberOfTitleLines, allowSelection: allowSelection, insets: insets, spacing: spacing, tapCallback: tapCallback, useChevron: useChevron, pasteBoardText: pasteBoardText, pasteBoardCompletion: pasteBoardCompletion)
        }, tapCallback: tapCallback, useChevron: useChevron)
        self.deleteAction = deleteAction
    }

}

open class TitleWithSubtitleView: CellView {
    
    public var isSelectable: Bool = false
    
    public var pasteBoardText: String?
    
    public var pasteBoardCompletion: Action?

    public let title: UILabel = {
        let label = UILabel()
        label.textColor = Color.Base.secondary
        label.font = Font.main(weight: .regular).withSize(14)
        return label
    }()

    public let subtitle: UITextView = {
        let textView = UITextView()
        textView.font = Font.main(weight: .regular).withSize(16)
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.dataDetectorTypes = .all
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.backgroundColor = .clear
        textView.tintColor = Color.Base.brandTint
        textView.isSelectable = false
        return textView
    }()
    
    public var titleConstraints: AnchoredConstraints?
    
    public var subtitleConstraints: AnchoredConstraints?
    
    public var titleAndSubtitleSpaceConstraint: NSLayoutConstraint?

    open override func commonInit() {
        addSubview(title)
        titleConstraints = title.stickToSuperviewEdges([.left, .top, .right], insets: .init(top: 11, left: 16, bottom: 0, right: 16))

        addSubview(subtitle)
        subtitleConstraints = subtitle.stickToSuperviewEdges([.left, .right, .bottom], insets: .init(top: 0, left: 16, bottom: 13, right: 16))
        titleAndSubtitleSpaceConstraint = subtitle.top(2, to: title)
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
        addGestureRecognizer(gesture)
    }

    @objc private func longTap(sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else { return }
        if let pasteBoardText = pasteBoardText {
            UIPasteboard.general.string = pasteBoardText
            pasteBoardCompletion?()
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        }
    }
    
    open override func setSelectedUI(selected: Bool) {
        if isSelectable {
            backgroundColor = selected ? Color.Base.selection : Color.Base.mainBackground
        }
    }
    
    open func update(
        title: String,
        text: String?,
        attributedText: NSAttributedString?,
        numberOfTitleLines: Int = 1,
        allowSelection: Bool = false,
        insets: UIEdgeInsets = .init(top: 11, left: 16, bottom: 13, right: 11),
        spacing: CGFloat = 2,
        tapCallback: Action? = nil,
        useChevron: Bool = false,
        pasteBoardText: String? = nil,
        pasteBoardCompletion: Action? = nil
    ) {
        if let attributedText = attributedText {
            subtitle.attributedText = attributedText
        } else {
            subtitle.attributedText = nil
            subtitle.text = text
        }
        self.title.text = title
        self.title.numberOfLines = numberOfTitleLines
        self.subtitle.isSelectable = allowSelection
        self.subtitle.isUserInteractionEnabled = allowSelection
        self.subtitle.dataDetectorTypes = allowSelection ? .all : []
        self.isSelectable = tapCallback != nil
        self.pasteBoardText = pasteBoardText
        self.pasteBoardCompletion = pasteBoardCompletion
        
        // update constraints
        titleConstraints?.updateInsets(insets)
        subtitleConstraints?.updateInsets(insets)
        titleAndSubtitleSpaceConstraint?.constant = spacing
        layoutIfNeeded()
    }
    
}
