import UIKit
import HSEUI

public class ImageDisplayerViewController: UIPageViewController, ImageViewerTransitionViewControllerConvertible {
    
    public enum DismissStyle {
        case disappear, `default`
    }
    
    unowned var initialSourceView: UIImageView?
    
    var sourceView: UIImageView? {
        guard let vc = viewControllers?.first as? ImageViewerController else { return nil }
        return initialIndex == vc.index ? initialSourceView : nil
    }
    
    var targetView: UIImageView? {
        (viewControllers?.first as? ImageViewerController)?.imageView
    }
    
    private var imageDataSource: ImageDataSource?
 
    private var initialIndex: Int
    
    private var dismissAnimationStyle: DismissStyle
    
    private(set) lazy var navBar: UINavigationBar = {
        let navBar = UINavigationBar(frame: .zero)
        navBar.isTranslucent = true
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        return navBar
    }()
    
    private(set) lazy var backgroundView: UIView? = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 1.0
        return view
    }()
    
    private(set) lazy var navItem = UINavigationItem()
    
    private let imageViewerPresentationDelegate = ImageViewerTransitionPresentationManager()
    
    public init(
        sourceView: UIImageView,
        imageDataSource: ImageDataSource?,
        dismissAnimationStyle: DismissStyle = .default,
        initialIndex: Int = 0
    ) {
        self.initialSourceView = sourceView
        self.initialIndex = initialIndex
        self.imageDataSource = imageDataSource
        self.dismissAnimationStyle = dismissAnimationStyle
        let pageOptions = [UIPageViewController.OptionsKey.interPageSpacing: 20]
        
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: pageOptions)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        initialSourceView?.alpha = 1.0
    }
    
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func commonInit() {
        transitioningDelegate = imageViewerPresentationDelegate
        modalPresentationStyle = .custom
        modalPresentationCapturesStatusBarAppearance = true
        dataSource = self
        
        setUpNavBar()
        
        view.addSubview(navBar)
        navBar.stickToSuperviewSafeEdges([.left, .right, .top])
        
        if let backgroundView = backgroundView {
            view.addSubview(backgroundView)
            backgroundView.stickToSuperviewEdges(.all)
            view.sendSubviewToBack(backgroundView)
        }
        
        if let imageDatasource = imageDataSource {
            let initialVC = ImageViewerController(
                index: initialIndex,
                imageItem: imageDatasource.imageItem(at: initialIndex)
            )
            setViewControllers([initialVC], direction: .forward, animated: true)
        }
    }
    
    private func setUpNavBar() {
        let closeButton = UIButton()
        closeButton.setImage(sfSymbol("xmark", tintColor: Color.Base.white), for: .normal)
        closeButton.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        closeButton.imageView?.layer.shadowOpacity = 0.5
        closeButton.imageView?.layer.shadowRadius = 5
        closeButton.imageView?.layer.shadowColor = Color.Base.black.cgColor
        closeButton.imageView?.layer.shadowOffset = .init(width: 1, height: 2)
        closeButton.imageView?.layer.masksToBounds = false
        navItem.leftBarButtonItem = UIBarButtonItem(customView: closeButton)
        navBar.alpha = 0.0
        navBar.items = [navItem]
    }

    @objc private func dismiss(_ sender:UIBarButtonItem) {
        switch dismissAnimationStyle {
        case .disappear:
            sourceView?.alpha = 1.0
            UIView.animate(withDuration: 0.235, animations: {
                self.view.alpha = 0.0
            }) { _ in
                self.dismiss(animated: false, completion: nil)
            }
        case .default:
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension ImageDisplayerViewController: UIPageViewControllerDataSource {
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let vc = viewController as? ImageViewerController else { return nil }
        guard let imageDatasource = imageDataSource else { return nil }
        guard vc.index > 0 else { return nil }
 
        let newIndex = vc.index - 1
        return ImageViewerController.init(index: newIndex, imageItem:  imageDatasource.imageItem(at: newIndex))
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let vc = viewController as? ImageViewerController else { return nil }
        guard let imageDatasource = imageDataSource else { return nil }
        guard vc.index <= (imageDatasource.numberOfImages() - 2) else { return nil }
        
        let newIndex = vc.index + 1
        return ImageViewerController.init(index: newIndex, imageItem: imageDatasource.imageItem(at: newIndex))
    }
}
