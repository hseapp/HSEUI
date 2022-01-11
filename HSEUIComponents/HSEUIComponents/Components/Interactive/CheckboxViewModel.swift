import UIKit
import HSEUI

public class CheckboxViewModel: CellViewModel {

    public var isChecked: Bool = false {
        didSet {
            apply(type: CheckboxView.self) { (view) in
                view.isChecked = isChecked
            }
        }
    }

    public let columnsInRow: Int

    public init(text: String, isChecked: Bool, checkChanged: ((Bool) -> Void)? = nil, columnsInRow: Int = 1) {
        self.columnsInRow = columnsInRow
        self.isChecked = isChecked
        super.init(view: CheckboxView.self)
        let configurator = CellViewConfigurator<CheckboxView>.builder()
            .setConfigureView({ [weak self] (view) in
                view.checkChanged = {
                    self?.isChecked = $0
                    checkChanged?($0)
                }
                view.isChecked = self?.isChecked ?? isChecked
                view.updateUIForCurrentState()
                view.text = text
            })
            .setTapCallback({ [weak self] in
                self?.apply(type: CheckboxView.self) { (view) in
                    view.isChecked.toggle()
                    view.animateUIForCurrentState()
                    view.checkChanged?(view.isChecked)
                }
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            })
            .setUseChevron(false)
            .build()
        updateConfigurator(configurator)
        voiceOver.accessibilityTraits = UISwitch().accessibilityTraits
    }

    public override func preferredWidth(for parentWidth: CGFloat) -> CGFloat? {
        return parentWidth / CGFloat(columnsInRow)
    }

}

public class CheckboxView: CellView {

    public var isChecked: Bool = false
    
    public func updateUIForCurrentState() {
        if self.isChecked {
            self.imageView.image = image
            self.imageView.layer.borderWidth = 0
            self.imageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        } else {
            self.imageView.image = nil
            self.imageView.layer.borderWidth = 2
            self.imageView.transform = .identity
        }
    }
    
    private let image: UIImage = {
        return UIImage(named: "checkbox_on", in: .current, with: .none)!
    }()
    
    public func animateUIForCurrentState() {
        UIView.transition(with: imageView,
                          duration: 0.2,
                          options: .transitionCrossDissolve,
                          animations: { self.updateUIForCurrentState() },
                          completion: nil)
    }

    public var text: String? {
        didSet {
            label.text = text
        }
    }

    public var checkChanged: ((Bool) -> Void)?

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = Font.main(weight: .regular).withSize(16)
        label.numberOfLines = 0
        return label
    }()

    public override func commonInit() {
        addSubview(imageView)
        imageView.stickToSuperviewEdges([.left], insets: .init(top: 12, left: 16, bottom: 0, right: 0))
        imageView.centerVertically()
        imageView.exactSize(.init(width: 20, height: 20))
    
        imageView.layer.borderColor = Color.Base.image.cgColor
        self.imageView.layer.cornerRadius = 4
        
        addSubview(label)
        label.leading(14, to: imageView)
        label.stickToSuperviewEdges([.right, .top, .bottom], insets: UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 16))
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        imageView.layer.borderColor = Color.Base.image.cgColor
    }

    public override func touchBegan() {
        UIView.animate(withDuration: 0.1) {
            self.imageView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.imageView.alpha = 0.5
            self.imageView.layer.borderWidth = 0
        }
        UIView.transition(with: imageView,
                          duration: 0.1,
                          options: .transitionCrossDissolve,
                          animations: { self.imageView.image = self.image },
                          completion: nil)
    }

    public override func touchEnded() {
        UIView.animate(withDuration: 0.2) {
            self.imageView.transform = .identity
            self.imageView.alpha = 1
            self.imageView.layer.borderWidth = 2
        }
        UIView.transition(with: imageView,
                          duration: 0.1,
                          options: .transitionCrossDissolve,
                          animations: { self.imageView.image = nil },
                          completion: nil)
    }

}
