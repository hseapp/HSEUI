import UIKit
import HSEUI

open class BottomButtonView: UIView {

    public enum State {
        case enabled, disabled, unpainted
    }

    public var state: State = .enabled {
        didSet {
            if state != oldValue { updateUI() }
        }
    }

    private let button: UIButton
    
    public var isSeparatorHidden: Bool {
        get {
            return separator.isHidden
        }
        set {
            separator.isHidden = newValue
        }
    }

    let separator: UIView = {
        let view = UIView()
        view.backgroundColor = Color.Base.separator
        view.height(0.5)
        return view
    }()
    
    let cover = UIVisualEffectView(effect: UIBlurEffect(style: .defaultHSEUI))

    public var title: String = "" {
        didSet {
            button.setTitle(title, for: .normal)
        }
    }

    public var action: Action?

    public init(button: UIButton? = nil) {
        self.button = button ?? BrandButton()
        super.init(frame: .zero)
        setUpView()
        commonInit()
    }

    public convenience init(title: String, action: Action?) {
        self.init()
        button.setTitle(title, for: .normal)
        self.action = action
    }
    
    public convenience init(button: UIButton, action: Action?) {
        self.init(button: button)
        self.action = action
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView() {
//        backgroundColor = Color.Base.mainBackground
        backgroundColor = .clear
        button.titleLabel?.font = Font.main(weight: .medium)
        button.layer.borderColor = Color.Base.brandTint.cgColor
    }

    private func commonInit() {
        addSubview(cover)
        cover.stickToSuperviewEdges(.all)
        
        addSubview(button)
        button.stickToSuperviewSafeEdges(.all, insets: .init(top: 12, left: 12, bottom: 12, right: 12))
        button.height(45)
        
        addSubview(separator)
        separator.stickToSuperviewEdges([.top, .left, .right])

        if let btn = button as? BrandButton {
            btn.addAction { [weak self] in
                self?.action?()
            }
        } else {
            button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        }
    }
    
    @objc private func buttonTapped() {
        action?()
    }

    private func updateUI() {
        button.isEnabled = state != .disabled
        switch state {
        case .enabled:
            button.backgroundColor = Color.Base.brandTint
            button.setTitleColor(Color.Base.white, for: .normal)
            button.layer.borderWidth = 0
        case .disabled:
            button.backgroundColor = Color.Base.brandTint.withAlphaComponent(0.5)
            button.setTitleColor(Color.Base.white.withAlphaComponent(0.7), for: .normal)
            button.layer.borderWidth = 0
        case .unpainted:
            button.backgroundColor = Color.Base.mainBackground
            button.setTitleColor(Color.Base.brandTint, for: .normal)
            button.layer.borderWidth = 1
        }
    }

}
