import UIKit
import HSEUI

public struct OverflowData {

    // MARK: - Public Types
    
    public struct ButtonData {

        var title: String
        var style: BrandButton.Style
        var action: Action?
        
        public init(title: String,
                    style: BrandButton.Style,
                    action: Action? = nil) {

            self.title = title
            self.style = style
            self.action = action
        }

    }

    // MARK: - Public Properties
    
    public var image: UIImage?
    public var title, subtitle: String
    public var imageHeight: CGFloat
    public var buttons: [ButtonData]
    public var hideSubtitleOnFirstButtonLongTap: Bool

    // MARK: - Init
    
    public init(
        image: UIImage?,
        title: String,
        subtitle: String,
        buttonTitle: String = NSLocalizedString("common.try_again", comment: ""),
        buttonStyle: BrandButton.Style = .filled,
        imageHeight: CGFloat = 164,
        buttonAction: Action? = nil,
        hideSubtitleOnFirstButtonLongTap: Bool = false
    ) {
        self.image = image
        self.title = title
        self.subtitle = subtitle
        self.imageHeight = imageHeight
        self.hideSubtitleOnFirstButtonLongTap = hideSubtitleOnFirstButtonLongTap
        
        self.buttons = [ButtonData(title: buttonTitle,
                                   style: buttonStyle,
                                   action: buttonAction)]
    }
    
    public init(
        image: UIImage?,
        title: String,
        subtitle: String,
        imageHeight: CGFloat = 164,
        buttons: [ButtonData] = [],
        hideSubtitleOnFirstButtonLongTap: Bool = false
    ) {
        self.image = image
        self.title = title
        self.subtitle = subtitle
        self.imageHeight = imageHeight
        self.buttons = buttons
        self.hideSubtitleOnFirstButtonLongTap = hideSubtitleOnFirstButtonLongTap
    }

    // MARK: - Public Methods
    
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
    
    // MARK: - Properties
    
    public override var blocksSkeletonisation: Bool {
        return true
    }
    
    public var data: OverflowData {
        didSet { update() }
    }
    
    // MARK: - Init
    
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

    // MARK: - Open Methods
    
    open func update() {
        // remove arranged subviews
        let subviews = stack.arrangedSubviews
        subviews.forEach { stack.removeArrangedSubview($0); $0.removeFromSuperview() }
        
        // fill stack
        if let img = data.image {
            let imageView = createImageView()
            imageView.image = img
            imageView.heightAnchor.constraint(lessThanOrEqualToConstant: data.imageHeight).isActive = true
            stack.addArrangedSubview(imageView)
        }
        stack.addArrangedSubview(title)

        let buttons = data.buttons.filter({ $0.action != nil }).map({ createButton(data: $0) })
        buttons.forEach { stack.addArrangedSubview($0) }

        if data.hideSubtitleOnFirstButtonLongTap {
            let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(onFirstButtonLongTap))
            gestureRecognizer.minimumPressDuration = 2.0
            buttons.first?.addGestureRecognizer(gestureRecognizer)
        }
        else {
            stack.addArrangedSubview(subtitle)
            stack.setCustomSpacing(27, after: subtitle)
        }
        
        // set up
        title.text = data.title
        subtitle.setAttributedText(data.subtitle, kern: 0.15, lineSpacing: 1.1)
        
        stack.setCustomSpacing(8, after: title)
        buttons.forEach { stack.setCustomSpacing(15, after: $0) }
    }

    // MARK: - Private Methods

    private func commonInit() {
        addSubview(stack)
        stack.stickToSuperviewEdges(.all, insets: .init(top: 0, left: 16, bottom: 0, right: 16))
    }

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

    @objc private func onFirstButtonLongTap() {
        guard
            let titleIndex = stack.arrangedSubviews.firstIndex(of: title),
            !stack.arrangedSubviews.contains(subtitle)
        else {
            return
        }

        UIView.transition(with: stack, duration: 0.5) { [weak self] in
            guard let self = self else { return }
            self.stack.insertArrangedSubview(self.subtitle, at: titleIndex + 1)
            self.stack.setCustomSpacing(27, after: self.subtitle)
        }

        superview?.layoutIfNeeded()
    }
    
}
