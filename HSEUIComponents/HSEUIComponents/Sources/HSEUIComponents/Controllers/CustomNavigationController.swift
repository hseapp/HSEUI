import UIKit
import HSEUI

open class CustomNavigationController: UINavigationController {

    private let line: UIView = {
        let line = UIView()
        line.backgroundColor = Color.Base.separator
        return line
    }()

    public var isLineHidden: Bool = false {
        didSet {
            line.isHidden = isLineHidden
        }
    }
    
    public var isBlurHidden: Bool = false {
        didSet {
            blur.isHidden = isBlurHidden
        }
    }
    
    private var currentViewController: UIViewController
    
    private var nextController: UIViewController?

    public override init(rootViewController: UIViewController) {
        self.currentViewController = rootViewController
        
        super.init(rootViewController: rootViewController)
        commonInit()

        if #available(iOS 14.0, *) {
            rootViewController.navigationItem.backButtonDisplayMode = .minimal
            rootViewController.navigationController?.navigationBar.tintColor = Color.Base.brandTint
        } else {
            rootViewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            rootViewController.navigationItem.backBarButtonItem?.tintColor = Color.Base.brandTint
        }

        rootViewController.extendedLayoutIncludesOpaqueBars = true
    }
    
    open override func willMove(toParent parent: UIViewController?) {
        self.preferredContentSize = self.view.systemLayoutSizeFitting(
            UIView.layoutFittingCompressedSize
        )
    }

    public convenience init() {
        self.init(rootViewController: UIViewController())
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func setupNavBar(_ navigationBar: UINavigationBar, line: UIView) {
        navigationBar.standardAppearance.configureWithTransparentBackground()
        navigationBar.compactAppearance?.configureWithTransparentBackground()
        navigationBar.scrollEdgeAppearance?.configureWithTransparentBackground()
        
        navigationBar.barTintColor = Color.Base.mainBackground
        navigationBar.tintColor = Color.Base.brandTint
        navigationBar.titleTextAttributes = [.font: Font.main(weight: .semibold).withSize(17)]
        
        navigationBar.addSubview(line)
        line.stickToSuperviewEdges([.left, .bottom, .right])
        line.height(0.5)
    }
    
    private let blur = UIVisualEffectView(effect: UIBlurEffect(style: .defaultHSEUI))

    private func commonInit() {
        self.view.addSubview(blur)
        self.view.bringSubviewToFront(self.navigationBar)
        blur.stickToSuperviewEdges([.left, .right, .top])
        blur.bottomAnchor.constraint(equalTo: self.navigationBar.bottomAnchor).isActive = true
        
        Self.setupNavBar(navigationBar, line: line)
        
        delegate = self
        interactivePopGestureRecognizer?.delegate = self
        interactivePopGestureRecognizer?.addTarget(self, action: #selector(handlePopGesture))
    }

    public override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        viewController.extendedLayoutIncludesOpaqueBars = true
        super.pushViewController(viewController, animated: animated)
    }
    
    public func pushViewController(_ viewController: UIViewController, animated: Bool, completion: Action?) {
        CATransaction.begin()
        pushViewController(viewController, animated: animated)
        CATransaction.setCompletionBlock(completion)
        CATransaction.commit()
    }
    
    // MARK: - top view
    
    private var _topViews: [UIViewController: UIView] = [:]
    
    public var topViews: [UIViewController: UIView] {
        set {
            if let parent = self.parent as? CustomNavigationController {
                parent.topViews = newValue
            } else {
                _topViews = newValue
            }
        }
        get {
            (parent as? CustomNavigationController)?.topViews ?? _topViews
        }
    }
    
    public func addTopView(_ topView: UIView, for controller: UIViewController) {
        view.addSubview(topView)
        topView.top(to: navigationBar)
        topView.stickToSuperviewEdges([.left, .right])
        
        topViews[controller] = topView
    }
    
    @objc private func handlePopGesture(_ gesture: UIGestureRecognizer) {
        guard let controller = nextController, let topView = topViews[controller] else { return }
        let width = view.bounds.width
        let translation = gesture.location(in: view)
        let alpha = 1 - (width - translation.x) / width
        
        topView.alpha = alpha
    }

}

extension CustomNavigationController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer is UIScreenEdgePanGestureRecognizer
    }
    
}

extension CustomNavigationController: UINavigationControllerDelegate {
    
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        interactivePopGestureRecognizer?.isEnabled = self.viewControllers.count > 1
        topViews.forEach({ controller, view in
            view.alpha = viewController.unwrapped == controller.unwrapped ? 1 : 0
            view.isHidden = viewController.unwrapped != controller.unwrapped
        })
        currentViewController = viewController.unwrapped
        nextController = nil
    }

    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        nextController = viewController.unwrapped
        topViews[currentViewController]?.alpha = 0
        topViews[viewController.unwrapped]?.isHidden = false
    }
    
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        topViews[fromVC.unwrapped]?.alpha = 0
        topViews[toVC.unwrapped]?.alpha = 1
        
        return nil
    }
    
}

fileprivate extension UIViewController {
    
    var unwrapped: UIViewController {
        (self as? UINavigationController)?.viewControllers.first ?? self
    }
    
}
