import UIKit
import HSEUI

// ---------------------------------------------------------------------------------------------
// brand button is a blue button with rounded corners and animated selection

public class BrandButton: UIButton {
    
    public enum Style {
        case filled, tinted, white, `default`, custom(title: UIColor, background: UIColor)
    }

    // MARK: - properties
    public var scale: CGFloat = 0.97

    public var duration: Double = 0.1
    
    public var style: Style = .filled {
        didSet { updateUI() }
    }

    private var action: Action?

    // MARK: - init

    public override init(frame: CGRect) {
        super.init(frame: frame)

        layer.cornerRadius = 10
        backgroundColor = Color.Base.brandTint
        setTitleColor(.white, for: .normal)
        titleLabel?.font = Font.main(weight: .medium).withSize(15)
    }

    public convenience init(title: String) {
        self.init(frame: .zero)
        setTitle(title, for: .normal)
    }

    public required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func updateUI() {
        switch style {
        case .filled:
            backgroundColor = Color.Base.brandTint
            setTitleColor(.white, for: .normal)
        case .tinted:
            backgroundColor = Color.Base.brandTint.withAlphaComponent(0.08)
            setTitleColor(Color.Base.brandTint, for: .normal)
        case .white:
            backgroundColor = .white
            setTitleColor(Color.Base.black, for: .normal)
        case .default:
            backgroundColor = .clear
            setTitleColor(Color.Base.brandTint, for: .normal)
        case .custom(title: let titleColor, background: let backgroundColor):
            self.backgroundColor = backgroundColor
            setTitleColor(titleColor, for: .normal)
        }
    }

    // MARK: - touch action
    /// method to set action that will be executed when user touches the button
    public func addAction(_ action: @escaping Action) {
        self.action = action
    }

    public override func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        assertionFailure("Should be used `addAction` method instead")
    }

    // MARK: - touches handle
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        animate(for: .began)
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        animate(for: .ended, completion: {
            if let location = touches.first?.location(in: self) {
                if location.x >= 0 &&
                    location.x <= self.bounds.width &&
                    location.y >= 0 &&
                    location.y <= self.bounds.height {
                    self.action?()
                }
            }
        })
    }

    // MARK: - touches animation
    private func animate(for state: UIGestureRecognizer.State, completion: Action? = nil) {
        if state == .began {
            UIView.animate(withDuration: duration, delay: 0, options: [], animations: {
                self.transform = CGAffineTransform(scaleX: self.scale, y: self.scale)
            })
        } else if state == .ended {
            UIView.animate(withDuration: duration, delay: 0, options: [], animations: {
                self.transform = .identity
            }, completion: { _ in
                completion?()
            })
        }
    }

}
