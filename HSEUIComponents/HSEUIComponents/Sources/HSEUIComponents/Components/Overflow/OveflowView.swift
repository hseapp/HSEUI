import UIKit
import HSEUI

public struct OverflowData {
    
    public struct ButtonData {
        var title: String
        var style: BrandButton.Style
        var action: Action?
        
        public init(title: String, style: BrandButton.Style, action: Action? = nil) {
            self.title = title
            self.style = style
            self.action = action
        }
    }
    
    public var image: UIImage?
    public var title, subtitle: String
    public var imageHeight: CGFloat
    public var buttons: [ButtonData]
    
    public init(
        image: UIImage?,
        title: String,
        subtitle: String,
        buttonTitle: String = NSLocalizedString("common.try_again", comment: ""),
        buttonStyle: BrandButton.Style = .filled,
        imageHeight: CGFloat = 164,
        buttonAction: Action? = nil
    ) {
        self.image = image
        self.title = title
        self.subtitle = subtitle
        self.imageHeight = imageHeight
        
        self.buttons = [ButtonData(title: buttonTitle, style: buttonStyle, action: buttonAction)]
    }
    
    public init(
        image: UIImage?,
        title: String,
        subtitle: String,
        imageHeight: CGFloat = 164,
        buttons: [ButtonData] = []
    ) {
        self.image = image
        self.title = title
        self.subtitle = subtitle
        self.imageHeight = imageHeight
        self.buttons = buttons
    }
    
    mutating public func addTapCallback(_ action: Action?, position: Int) {
        if buttons.count > position, let action = action {
            buttons[position].action = action
        }
    }
    
}

open class OverflowView: UIView {
    
    // MARK: - UI
    
    public let stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 28
        return stack
    }()
    
    public let title: UILabel = {
        let label = UILabel()
        label.font = Font.main(weight: .semibold)
        label.text = NSLocalizedString("common.error", comment: "")
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    public let subtitle: UILabel = {
        let label = UILabel()
        label.font = Font.main(weight: .regular).withSize(14)
        label.numberOfLines = 10
        label.textAlignment = .center
        label.textColor = Color.Base.secondary
        return label
    }()
    
    // MARK: - properties
    
    public override var blocksSkeletonisation: Bool {
        return true
    }
    
    public var data: OverflowData {
        didSet { update() }
    }
    
    // MARK: - init
    
    public init(data: OverflowData) {
        self.data = data
        super.init(frame: .zero)
        commonInit()
    }
    
    public convenience init(data: OverflowData, tapCallback: Action?) {
        var dataCopy = data
        dataCopy.addTapCallback(tapCallback, position: 0)
        self.init(data: dataCopy)
    }
    
    public convenience init() {
        self.init(data: .init(image: nil, title: "", subtitle: ""))
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - set up
    
    private func commonInit() {
        addSubview(stack)
        stack.stickToSuperviewEdges(.all, insets: .init(top: 0, left: 16, bottom: 0, right: 16))
    }
    
    // MARK: - views creation
    
    private func createImageView() -> UIImageView {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }
    
    private func createButton(data: OverflowData.ButtonData) -> BrandButton {
        let button = BrandButton(title: NSLocalizedString("common.try_again", comment: ""))
        button.contentEdgeInsets = .init(top: 8, left: 16, bottom: 8, right: 16)
        button.height(36)
        button.setTitle(data.title, for: .normal)
        button.style = data.style
        button.addAction {
            data.action?()
        }
        return button
    }
    
    // MARK: - update
    
    open func update() {
        // remove arranged subviews
        let subviews = stack.arrangedSubviews
        subviews.forEach({ stack.removeArrangedSubview($0); $0.removeFromSuperview() })
        
        // fill stack
        if let img = data.image {
            let imageView = createImageView()
            imageView.image = img
            imageView.heightAnchor.constraint(lessThanOrEqualToConstant: data.imageHeight).isActive = true
            stack.addArrangedSubview(imageView)
        }
        stack.addArrangedSubview(title)
        stack.addArrangedSubview(subtitle)
        
        let buttons = data.buttons.filter({ $0.action != nil }).map({ createButton(data: $0) })
        buttons.forEach({ stack.addArrangedSubview($0) })
        
        // set up
        title.text = data.title
        subtitle.setAttributedText(data.subtitle, kern: 0.15, lineSpacing: 1.1)
        
        stack.setCustomSpacing(8, after: title)
        stack.setCustomSpacing(27, after: subtitle)
        buttons.forEach({ stack.setCustomSpacing(15, after: $0) })
    }
    
}
