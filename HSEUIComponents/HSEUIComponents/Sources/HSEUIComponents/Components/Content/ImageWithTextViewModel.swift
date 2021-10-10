import UIKit
import HSEUI

public class ImageWithTextViewModel: CellViewModel {
    
    public enum Style {
        case `default`
        case primary
        case compact
    }
    
    convenience public init(
        image: UIImage,
        text: String?,
        style: Style = .default,
        numberOfLines: Int = 1,
        tintColor: UIColor = Color.Base.image,
        titleColor: UIColor = Color.Base.label,
        pasteBoardText: String? = nil,
        pasteBoardCompletion: Action? = nil,
        tapCallback: Action? = nil,
        useChevron: Bool? = nil
    ) {
        
        var textFont: UIFont
        var textInsets: UIEdgeInsets
        var imageSize: CGSize
        var imageInsets: UIEdgeInsets
        var minHeight: CGFloat
        
        switch style {
        case .default:
            textFont = Font.main(weight: .regular).withSize(15)
            textInsets = .init(top: 8, left: 12, bottom: 8, right: 16)
            imageSize = .init(width: 20, height: 20)
            imageInsets = .init(top: 8, left: 16, bottom: 0, right: 0)
            minHeight = 36
        case .primary:
            textFont = Font.main
            textInsets = .init(top: 12, left: 16, bottom: 14, right: 16)
            imageSize = .init(width: 28, height: 28)
            imageInsets = .init(top: 10, left: 16, bottom: 0, right: 0)
            minHeight = 48
        case .compact:
            textFont = Font.main(weight: .medium).withSize(14)
            textInsets = .init(top: 8, left: 12, bottom: 8, right: 16)
            imageSize = .init(width: 20, height: 20)
            imageInsets = .init(top: 8, left: 16, bottom: 0, right: 0)
            minHeight = 36
        }
        
        self.init(
            image: image,
            text: text,
            textFont: textFont,
            textInsets: textInsets,
            imageSize: imageSize,
            imageInsets: imageInsets,
            numberOfLines: numberOfLines,
            tintColor: tintColor,
            titleColor: titleColor,
            minHeight: minHeight,
            pasteBoardText: pasteBoardText,
            pasteBoardCompletion: pasteBoardCompletion,
            tapCallback: tapCallback,
            useChevron: useChevron
        )
    }
    
    public init(
        image: UIImage,
        text: String?,
        textFont: UIFont = Font.main(weight: .regular).withSize(15),
        textInsets: UIEdgeInsets = .init(top: 8, left: 12, bottom: 8, right: 16),
        imageSize: CGSize = .init(width: 20, height: 20),
        imageInsets: UIEdgeInsets = .init(top: 8, left: 16, bottom: 0, right: 0),
        numberOfLines: Int = 1,
        tintColor: UIColor = Color.Base.image,
        titleColor: UIColor = Color.Base.label,
        minHeight: CGFloat = 36,
        pasteBoardText: String? = nil,
        pasteBoardCompletion: Action? = nil,
        tapCallback: Action? = nil,
        useChevron: Bool? = nil
    ) {
        super.init(view: ImageWithTextView.self, configureView: { view in
            view.update(image: image, text: text, textFont: textFont, textInsets: textInsets, imageSize: imageSize, imageInsets: imageInsets, numberOfLines: numberOfLines, tintColor: tintColor, titleColor: titleColor, pasteBoardText: pasteBoardText, pasteBoardCompletion: pasteBoardCompletion, isSelectable: tapCallback != nil, minHeight: minHeight)
        }, tapCallback: tapCallback, useChevron: useChevron)
    }
    
}

open class ImageWithTextView: CellView {

    public var isSelectable = false

    public var pasteBoardCompletion: Action?

    public let imageView: ImageView = {
        let imageView = ImageView()
        let configuration = UIImage.SymbolConfiguration(weight: .medium)
        imageView.preferredSymbolConfiguration = configuration
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = nil
        return imageView
    }()

    public let title: UILabel = {
        let label = UILabel()
        label.font = Font.main(weight: .regular).withSize(15)
        return label
    }()
    
    public var imageViewConstraints: AnchoredConstraints?
    
    public var titleConstraints: AnchoredConstraints?

    public var pasteBoardText: String?
    
    open override func setUpView() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
        addGestureRecognizer(gesture)
    }

    open override func commonInit() {
        addSubview(imageView)
        imageViewConstraints = imageView.stickToSuperviewEdges([.top, .left], insets: .init(top: 8, left: 16, bottom: 0, right: 0))
        imageViewConstraints?.height = imageView.height(20)
        imageViewConstraints?.width = imageView.width(20)

        addSubview(title)
        titleConstraints = title.stickToSuperviewEdges([.top, .bottom, .right], insets: UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 16))
        titleConstraints?.leading = title.leading(12, to: imageView)
        
        heightConstraint = heightAnchor.constraint(greaterThanOrEqualToConstant: 36)
        heightConstraint?.isActive = true
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
        image: UIImage,
        text: String?,
        textFont: UIFont,
        textInsets: UIEdgeInsets,
        imageSize: CGSize,
        imageInsets: UIEdgeInsets,
        numberOfLines: Int,
        tintColor: UIColor,
        titleColor: UIColor,
        pasteBoardText: String?,
        pasteBoardCompletion: Action?,
        isSelectable: Bool,
        minHeight: CGFloat
    ) {
        self.imageView.image = image.withTintColor(tintColor, renderingMode: .alwaysOriginal)
        self.title.text = text
        self.title.font = textFont
        self.titleConstraints?.updateInsets(textInsets)
        self.imageViewConstraints?.updateSize(imageSize)
        self.imageViewConstraints?.updateInsets(imageInsets)
        self.title.numberOfLines = numberOfLines
        self.title.textColor = titleColor
        self.pasteBoardText = pasteBoardText
        self.pasteBoardCompletion = pasteBoardCompletion
        self.isSelectable = isSelectable
        self.heightConstraint?.constant = minHeight
    }
    
}
