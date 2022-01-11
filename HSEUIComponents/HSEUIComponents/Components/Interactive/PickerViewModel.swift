import UIKit
import HSEUI

public class PickerViewModel: CellViewModel {
    
    public var isSelectable: Bool
    
    private var text: String?
    
    private var placeholder: String?
    
    private var showImage: Bool
    
    public init(
        text: String?,
        placeholder: String?,
        header: String?,
        numberOfTextLines: Int = 0,
        showImage: Bool = true,
        isSelectable: Bool = true,
        isDisabled: Bool = false,
        width: CGFloat? = nil,
        infoCallback: Action? = nil,
        tapCallback: Action?,
        deleteAction: Action? = nil
    ) {
        self.showImage = showImage
        self.isSelectable = isSelectable
        self.text = text
        self.placeholder = placeholder
        super.init(view: PickerView.self)
        let configurator = CellViewConfigurator<PickerView>.builder()
            .setConfigureView { [weak self] view in
                guard let `self` = self else { return }
                view.update(text: self.text, placeholder: self.placeholder, headerText: header, numberOfLines: numberOfTextLines, width: width, showImage: self.showImage, isDisabled: isDisabled, infoCallback: infoCallback)
            }
            .setUseChevron(false)
            .setTapCallback { [weak self] in
                if self?.isSelectable == true {
                    tapCallback?()
                }
            }
            .build()
        updateConfigurator(configurator)
        
        self.deleteAction = deleteAction
    }
    
    public func updateText(_ text: String?) {
        self.text = text
        apply(type: PickerView.self) { view in
            view.updateText(text)
        }
    }
    
    public func updatePlaceholder(_ text: String?) {
        self.placeholder = text
        apply(type: PickerView.self) { view in
            view.updatePlaceholder(text)
        }
    }
    
    public func updateImage(showImage: Bool) {
        self.showImage = showImage
        apply(type: PickerView.self) { view in
            view.updateImage(showImage: showImage)
        }
    }
    
}

open class PickerView: CellView {
    
    private var placeholder: String?
    
    private var text: String?
    
    private var headerConstraints: AnchoredConstraints?
    
    private var imageWidthConstraint: NSLayoutConstraint?
    
    private var infoImageViewConstraint: AnchoredConstraints?
    
    private var infoCallback: Action?
    
    public var isDisabled: Bool = false
    
    public let header: UILabel = {
        let label = UILabel()
        label.font = Font.main(weight: .regular).withSize(14)
        label.textColor = Color.Base.secondary
        label.numberOfLines = 0
        return label
    }()
    
    public let valueLabel: UILabel = {
        let label = UILabel()
        label.font = Font.main(weight: .regular).withSize(16)
        label.textColor = Color.Base.secondary
        return label
    }()
    
    public let container: UIView = {
        let view = UIView()
        view.backgroundColor = Color.Base.grayBackground
        view.layer.cornerRadius = 10
        return view
    }()
    
    public let imageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "icons24Done24CheckCopy")
        iv.clipsToBounds = true
        return iv
    }()
    
    private lazy var infoImageView: ImageView = {
        let iv = ImageView()
        iv.placeholder = .symbol("questionmark.circle")
        iv.setTapAction { [weak self] in
            self?.infoCallback?()
        }
        return iv
    }()
    
    open override func commonInit() {
        addSubview(header)
        headerConstraints = header.stickToSuperviewEdges([.left, .right, .top], insets: .init(top: 14, left: 12, bottom: 0, right: 12))
        headerConstraints?.height = header.height(0, priority: .required)
        
        addSubview(container)
        container.top(8, to: header)
        container.stickToSuperviewEdges([.left, .bottom], insets: .init(top: 0, left: 12, bottom: 12, right: 12))
        
        container.addSubview(imageView)
        imageView.trailing(10)
        imageWidthConstraint = imageView.exactSize(.init(width: 24, height: 24)).width
        imageView.centerVertically()
        
        container.addSubview(valueLabel)
        valueLabel.stickToSuperviewEdges([.left, .top, .bottom], insets: .init(top: 12, left: 12, bottom: 12, right: 0))
        valueLabel.trailing(12, to: imageView)
        
        addSubview(infoImageView)
        infoImageViewConstraint = infoImageView.exactSize(.init(width: 26, height: 26))
        infoImageViewConstraint?.trailing = infoImageView.trailing(16)
        infoImageView.centerVertically(to: container)
        infoImageViewConstraint?.leading = infoImageView.leading(20, to: container)
    }
    
    open func update(
        text: String?,
        placeholder: String?,
        headerText: String?,
        numberOfLines: Int,
        width: CGFloat?,
        showImage: Bool,
        isDisabled: Bool,
        infoCallback: Action? = nil
    ) {
        self.isDisabled = isDisabled
        valueLabel.numberOfLines = numberOfLines
        updatePlaceholder(placeholder)
        updateText(text)
        
        if let headerText = headerText {
            header.text = headerText
            headerConstraints?.height?.isActive = false
            headerConstraints?.top?.constant = 14
        } else {
            headerConstraints?.height?.isActive = true
            headerConstraints?.top?.constant = 4
        }
        
        widthConstant = width
        updateImage(showImage: showImage)
        self.infoCallback = infoCallback
        updateInfoViewConstraints()
    }
    
    private func updateInfoViewConstraints() {
        if infoCallback == nil {
            infoImageViewConstraint?.leading?.constant = 0
            infoImageViewConstraint?.width?.constant = 0
        } else {
            infoImageViewConstraint?.leading?.constant = 20
            infoImageViewConstraint?.width?.constant = 26
        }
    }
    
    open func updateText(_ text: String?) {
        self.text = text
        if let text = text, !text.isEmpty {
            valueLabel.text = text
            valueLabel.textColor = isDisabled ? Color.Base.secondary.withAlphaComponent(0.5) :  Color.Base.label
        } else {
            valueLabel.text = placeholder
            valueLabel.textColor = isDisabled ? Color.Base.secondary.withAlphaComponent(0.5) : Color.Base.placeholder
        }
    }
    
    open func updatePlaceholder(_ value: String?) {
        self.placeholder = value
        if text == nil {
            valueLabel.text = placeholder
            valueLabel.textColor = isDisabled ? Color.Base.secondary.withAlphaComponent(0.5) : Color.Base.placeholder
        }
    }
    
    open func updateImage(showImage: Bool) {
        imageView.isHidden = !showImage
        imageWidthConstraint?.constant = showImage ? 24 : 0
        imageView.image = isDisabled ? #imageLiteral(resourceName: "icons24Done24CheckCopy").withTintColor(Color.Base.image.withAlphaComponent(0.4), renderingMode: .alwaysOriginal) :  #imageLiteral(resourceName: "icons24Done24CheckCopy")
    }
    
}
