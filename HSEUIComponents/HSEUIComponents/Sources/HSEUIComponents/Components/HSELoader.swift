import UIKit
import HSEUI

//public class HSELoader: UIView {
//
//    public enum Theme {
//        case light, dark, system
//    }
//
//    private let imageView: UIImageView = {
//        let iv = UIImageView()
//        iv.clipsToBounds = true
//        return iv
//    }()
//
//    private let images: [UIImage] = [UIImage(named: "hse24", in: .current, with: .none)!.withTintColor(Color.Base.brandTint).withRenderingMode(.alwaysTemplate)]
//
//    public override var intrinsicContentSize: CGSize {
//        return .init(width: 42, height: 42)
//    }
//
//    public var theme: Theme
//
//    public init(theme: Theme = .system) {
//        self.theme = theme
//        super.init(frame: .zero)
//        commonInit()
//        setupView()
//        startAnimating()
//        isAccessibilityElement = true
//        accessibilityLabel = NSLocalizedString("сommon.loading", comment: "")
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    private func commonInit() {
//        addSubview(imageView)
//        imageView.stickToSuperviewEdges(.all)
//    }
//
//    private func setupView() {
//        imageView.image = images.randomElement()
//
//        switch theme {
//        case .system:
//            backgroundColor = Color.Base.mainBackground
//        case .light:
//            backgroundColor = Color.Base.white
//        case .dark:
//            backgroundColor = Color.Base.black
//        }
//
//        layer.cornerRadius = 16
//        layer.shadowOpacity = 0.14
//        layer.shadowRadius = 6
//        layer.shadowColor = UIColor.label.cgColor
//        layer.shadowOffset = .init(width: 0, height: 2)
//        layer.masksToBounds = false
//    }
//
//    private func startAnimating() {
//        let pulse1 = CASpringAnimation(keyPath: "transform.scale")
//        pulse1.duration = 0.6
//        pulse1.fromValue = 1.0
//        pulse1.toValue = 1.12
//        pulse1.autoreverses = true
//        pulse1.repeatCount = 1
//        pulse1.initialVelocity = 0.5
//        pulse1.damping = 0.8
//
//        let animationGroup = CAAnimationGroup()
//        animationGroup.duration = 1.5
//        animationGroup.repeatCount = 1000
//        animationGroup.animations = [pulse1]
//
//        self.layer.add(animationGroup, forKey: "pulse")
//    }
//}

fileprivate class DummyTarget {
    
    private let callback: Action
    
    init(callback: @escaping Action) {
        self.callback = callback
    }
    
    @objc func target() {
        callback()
    }
    
}

public class HSELoader: UIView {
    
    public enum State {
        case progress(Double)
        case success
        case failed
    }
    
    public var cancel: Action?
    
    public var getState: (() -> State)?
    
    public enum Theme {
        case light, dark, system
    }

    public var theme: Theme

    public init(theme: Theme = .system) {
        self.theme = theme
        super.init(frame: .zero)
        isAccessibilityElement = true
        accessibilityLabel = NSLocalizedString("сommon.loading", comment: "")
        
        let link = CADisplayLink(target: DummyTarget { [weak self] in
            self?.setNeedsDisplay()
        }, selector: #selector(DummyTarget.target))
        link.add(to: .current, forMode: .default)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancelRequest)))
        
        exactSize(CGSize(width: 52, height: 52))
        backgroundColor = Color.Collection.table
        layer.cornerRadius = 8
        clipsToBounds = true
        
//        cancel = {
//            
//        }
    }
    
//    @objc private func drawAnimation() {
//        self.setNeedsDisplay()
//    }
    
    @objc private func cancelRequest() {
        self.cancel?()
        self.getState = nil
    }
    
    private var tickStartDate: Date?
    
    private var rotationStartDate: Date?
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        let rotationDuration: TimeInterval = 1
        let tickAnimationDuration: TimeInterval = 0.2
        let normalizedTimer = Double(Int((Date().timeIntervalSince1970 * 1000)) % Int(rotationDuration * 1000)) / (rotationDuration * 1000)
        
        if rotationStartDate == nil { rotationStartDate = Date() }
        let timeElapsed = Date().timeIntervalSince(rotationStartDate!)
        
        let defaultRatio = 0.1 + ((sin(timeElapsed)+1) * 0.5) * 0.7
        
        
        let state = getState?() ?? .progress(defaultRatio)
//        let ratio = CGFloat(progress?() ?? defaultRatio)
        
        Color.Base.brandTint.setStroke()
        
        switch state {
        case .progress(let progress):
            Color.Base.brandTint.setStroke()
            let ratio = 0.1 + progress * 0.85
            let defaultRotation = CGFloat.pi * 2 * normalizedTimer
            
            let arcPath = UIBezierPath()
            let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
            
            let radius: CGFloat = cancel == nil ? 12 : 18
            
            tickStartDate = nil
            arcPath.addArc(withCenter: center, radius: radius, startAngle: defaultRotation, endAngle: defaultRotation + .pi * 2 * ratio, clockwise: true)
            arcPath.lineWidth = 3
            arcPath.lineCapStyle = .round
            arcPath.stroke()
            if cancel != nil {
                let xRadius: CGFloat = 6
                let xPath = UIBezierPath()
                xPath.move(to: CGPoint(x: center.x - xRadius, y: center.y - xRadius))
                xPath.addLine(to: CGPoint(x: center.x + xRadius, y: center.y + xRadius))
                xPath.move(to: CGPoint(x: center.x - xRadius, y: center.y + xRadius))
                xPath.addLine(to: CGPoint(x: center.x + xRadius, y: center.y - xRadius))
                xPath.lineWidth = 3
                xPath.lineCapStyle = .round
                xPath.stroke()
            }
        case .failed:
            let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
            let markPath = UIBezierPath()
            markPath.move(to: CGPoint(x: center.x, y: center.y - 10))
            markPath.addLine(to: CGPoint(x: center.x, y: center.y + 3))
            markPath.move(to: CGPoint(x: center.x, y: center.y + 8))
            markPath.addLine(to: CGPoint(x: center.x, y: center.y + 10))
            markPath.lineWidth = 3
            markPath.lineCapStyle = .round
            markPath.stroke()
        case .success:
            let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
            if tickStartDate == nil { tickStartDate = Date() }
            let tickProgress = Date().timeIntervalSince(tickStartDate!) / tickAnimationDuration
            let tickSize: CGFloat = 8
            let offset: CGFloat = -4
            let tickPath = UIBezierPath()
            
            tickPath.move(to: CGPoint(x: offset + center.x - tickSize, y: center.y))
            
            let firstRatio = CGFloat(min(1, tickProgress / 0.5))
            let secondRatio = CGFloat(min(1, max(0, (tickProgress - 0.5) / 0.5)))
            
            tickPath.addLine(to: CGPoint(x: offset + center.x - (1 - firstRatio) * tickSize, y: center.y + tickSize * firstRatio))
            
            if secondRatio > 0 {
                tickPath.addLine(to: CGPoint(x: offset + center.x + tickSize * 2 * secondRatio, y: center.y - tickSize * (-1 + 2*secondRatio)))
            }
            
            tickPath.lineWidth = 3
            tickPath.lineCapStyle = .round
            tickPath.lineJoinStyle = .round
            tickPath.stroke()
        }
//        print("render", ratio)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
