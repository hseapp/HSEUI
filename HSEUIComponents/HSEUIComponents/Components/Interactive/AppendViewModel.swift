import UIKit
import HSEUI

public class AppendViewModel: CellViewModel {
    
    public enum Style {
        case compact
        case primary
    }
    
    public init(
        text: String,
        image: ImageCreation?,
        header: String? = nil,
        imageSize: CGSize = .init(width: 28, height: 28),
        tintColor: UIColor = Color.Base.brandTint,
        font: UIFont = Font.main,
        insets: UIEdgeInsets = .init(top: 10, left: 16, bottom: 10, right: 12),
        spacing: CGFloat = 12,
        isEnabled: Bool = true,
        tapCallback: Action? = nil
    ) {
        super.init(view: AppendView.self, configureView: { view in
            view.update(text: text, image: image, headerText: header, imageSize: imageSize, tintColor: tintColor, font: font, insets: insets, spacing: spacing, isEnabled: isEnabled)
        }, tapCallback: tapCallback, useChevron: false)
    }
    
    public convenience init(
        text: String,
        image: UIImage? = sfSymbol("plus"),
        header: String? = nil,
        style: Style = .compact,
        isEnabled: Bool = true,
        tapCallback: Action? = nil
    ) {
        let imageSize: CGSize
        let font: UIFont = Font.main(weight: .medium)
        let imageCreation: ImageCreation
        let insets: UIEdgeInsets
        let spacing: CGFloat
        
        switch style {
        case .compact:
            imageSize = .init(width: 28, height: 28)
            imageCreation = {
                image?.withTintColor(Color.Base.brandTint, renderingMode: .alwaysOriginal)
            }
            insets = .init(top: 10, left: 16, bottom: 10, right: 16)
            spacing = 16
        case .primary:
            imageSize = .init(width: 48, height: 48)
            imageCreation = {
                drawImage(size: imageSize, image: image?.withTintColor(Color.Base.brandTint, renderingMode: .alwaysOriginal), imageSize: .init(width: 26, height: 26), backgroundColor: Color.Base.imageBackground, rounded: true, roundedImage: false)
            }
            insets = .init(top: 6, left: 16, bottom: 6, right: 12)
            spacing = 12
        }
        self.init(text: text, image: imageCreation, header: header, imageSize: imageSize, font: font, insets: insets, spacing: spacing, isEnabled: isEnabled, tapCallback: tapCallback)
    }
    
}

open class AppendView: CellView {

    public var image: ImageCreation? {
        didSet {
            imageView.image = image?()
        }
    }
    
    public let header: UILabel = {
        let label = UILabel()
        label.font = Font.main(weight: .regular).withSize(14)
        label.textColor = Color.Base.secondary
        label.numberOfLines = 0
        return label
    }()
    
    public let title: UILabel = {
        let label = UILabel()
        label.font = Font.main
        label.textColor = Color.Base.brandTint
        return label
    }()

    public let imageView: ImageView = {
        let iv = ImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFit
        iv.backgroundColor = .clear
        return iv
    }()
    
    public var headerConstraints: AnchoredConstraints?
    
    public var imageViewConstraints: AnchoredConstraints?
    
    public var spacingConstraint: NSLayoutConstraint?
    
    public var titleTrailingConstraint: NSLayoutConstraint?

    open override func commonInit() {
        addSubview(header)
        headerConstraints = header.stickToSuperviewEdges([.left, .right, .top], insets: .init(top: 12, left: 12, bottom: 0, right: 12))
        headerConstraints?.height = header.height(0, priority: .required)
        
        addSubview(imageView)
        imageViewConstraints = imageView.stickToSuperviewEdges([.left, .bottom], insets: .init(top: 0, left: 16, bottom: 10, right: 0))
        imageViewConstraints?.height = imageView.height(28)
        imageViewConstraints?.width = imageView.width(28)
        imageViewConstraints?.top = imageView.top(8, to: header)

        addSubview(title)
        title.centerVertically(to: imageView)
        spacingConstraint = title.leading(16, to: imageView)
        titleTrailingConstraint = title.trailing(16)
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        imageView.image = image?()
    }

    open override func setSelectedUI(selected: Bool) {
        title.textColor = selected ? tintColor.withAlphaComponent(0.5) : tintColor
        imageView.alpha = selected ? 0.5 : 1
    }
    
    public func update(
        text: String,
        image: ImageCreation?,
        headerText: String?,
        imageSize: CGSize,
        tintColor: UIColor,
        font: UIFont,
        insets: UIEdgeInsets,
        spacing: CGFloat,
        isEnabled: Bool
    ) {
        title.text = text
        title.font = font
        self.tintColor = tintColor
        self.image = image
        
        self.imageView.alpha = isEnabled ? 1 : 0.5
        self.title.alpha = isEnabled ? 1 : 0.5
        self.isUserInteractionEnabled = isEnabled
        
        imageViewConstraints?.updateSize(imageSize)
        imageViewConstraints?.leading?.constant = insets.left
        imageViewConstraints?.bottom?.constant = -insets.bottom
        
        if let headerText = headerText {
            header.text = headerText
            headerConstraints?.height?.isActive = false
            headerConstraints?.top?.constant = 14
            headerConstraints?.trailing?.constant = -insets.right
            imageViewConstraints?.top?.constant = 8
        } else {
            headerConstraints?.height?.isActive = true
            headerConstraints?.top?.constant = 0
            imageViewConstraints?.top?.constant = insets.top
        }
        
        titleTrailingConstraint?.constant = -insets.right
        spacingConstraint?.constant = spacing
        
        layoutIfNeeded()
    }

}
