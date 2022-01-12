import HSEUI
import UIKit

public class HSERefreshControlView: UIView, RefreshControlViewProtocol {
    
    private let imageView: UIImageView

    private let images: [UIImage] = [
        UIImage(named: "nointernet", in: .current, with: .none)!,
        UIImage(named: "nodata", in: .current, with: .none)!,
        UIImage(named: "hse24", in: .current, with: .none)!.withTintColor(Color.Base.brandTint).withRenderingMode(.alwaysTemplate),
        UIImage(named: "accountChoice", in: .current, with: .none)!
    ]
    
    required public init() {
        imageView = UIImageView(image: images.randomElement())
        super.init(frame: .zero)
        addSubview(imageView)
    }
    
    private var isImageExpired = false
    
    public override func layoutSubviews() {
        let size = max(0, min(42, frame.height - 16))
        imageView.frame = CGRect(x: frame.width/2 - size/2, y: frame.height/2 - size/2, width: size, height: size)
        if frame.height < 16 {
            if isImageExpired {
                imageView.image = images.filter{ imageView.image != $0 }.randomElement()
                isImageExpired = false
            }
        } else {
            isImageExpired = true
        }
        super.layoutSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func startAnimating() {
        let pulse1 = CASpringAnimation(keyPath: "transform.scale")
        pulse1.duration = 0.6
        pulse1.fromValue = 1.0
        pulse1.toValue = 1.12
        pulse1.autoreverses = true
        pulse1.repeatCount = 1
        pulse1.initialVelocity = 0.5
        pulse1.damping = 0.8

        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 1.5
        animationGroup.repeatCount = 1000
        animationGroup.animations = [pulse1]

        self.imageView.layer.add(animationGroup, forKey: "pulse")
    }
    
    public func stopAnimating() {
        self.layer.removeAllAnimations()
    }
    
}
