import UIKit
import HSEUI

public class ActionButtonViewModel: CellViewModel {

    public var isEnabled: Bool = true {
        didSet {
            apply(type: ActionButtonView.self) { (view) in
                view.isEnabled = isEnabled
            }
        }
    }

    public init(
        title: String,
        font: UIFont = Font.main(weight: .medium).withSize(15),
        height: CGFloat? = nil,
        insets: UIEdgeInsets = .init(top: 8, left: 16, bottom: 8, right: 16),
        backgroundColor: UIColor? = Color.Base.brandTint,
        style: BrandButton.Style = .filled,
        action: @escaping Action
    ) {
        super.init(view: ActionButtonView.self)
        
        let configurator = CellViewConfigurator<ActionButtonView>.builder()
            .setConfigureView({ [weak self] view in
                view.button.setTitle(title, for: .normal)
                view.button.titleLabel?.font = font
                view.button.addAction {
                    action()
                }
                view.isEnabled = self?.isEnabled ?? false
                view.changeConstraints(height: height, insets: insets)
                view.button.backgroundColor = backgroundColor
                view.button.style = style
            })
            .build()
        updateConfigurator(configurator)
    }

    public override func preferredWidth(for parentWidth: CGFloat) -> CGFloat? {
        return parentWidth
    }
}

class ActionButtonView: CellView {

    var isEnabled: Bool = true {
        didSet {
            button.isEnabled = isEnabled
            button.backgroundColor = isEnabled ? Color.Base.brandTint : Color.Base.brandTint.withAlphaComponent(0.5)
        }
    }

    let button = BrandButton()
    
    private var buttonConstraints: AnchoredConstraints?

    override func commonInit() {
        addSubview(button)
        buttonConstraints = button.stickToSuperviewEdges(.all, insets: .init(top: 8, left: 16, bottom: 8, right: 16))
        buttonConstraints?.height = button.height(36)
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    }

    func changeConstraints(height: CGFloat? = nil, insets: UIEdgeInsets) {
        if let height = height {
            buttonConstraints?.height?.constant = height
        }
        
        buttonConstraints?.updateInsets(insets)

        layoutIfNeeded()
    }

}
