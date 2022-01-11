import Foundation
import UIKit


fileprivate extension UIView {
    func frameRelativeToWindow() -> CGRect {
        return convert(bounds, to: nil)
    }
}

protocol ImageViewerTransitionViewControllerConvertible {
    var sourceView: UIImageView? { get }
    var targetView: UIImageView? { get }
}

final class ImageViewerTransitionPresentationAnimator: NSObject {
    
    let isPresenting: Bool
    
    init(isPresenting: Bool) {
        self.isPresenting = isPresenting
        super.init()
    }
}

// MARK: - UIViewControllerAnimatedTransitioning
extension ImageViewerTransitionPresentationAnimator: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let key: UITransitionContextViewControllerKey = isPresenting ? .to : .from
        guard let controller = transitionContext.viewController(forKey: key)
        else { return }
        
        let animationDuration = transitionDuration(using: transitionContext)
        
        if isPresenting {
            presentAnimation(
                transitionView: transitionContext.containerView,
                controller: controller,
                duration: animationDuration
            ) { finished in
                transitionContext.completeTransition(finished)
            }
            
        } else {
            dismissAnimation(
                transitionView: transitionContext.containerView,
                controller: controller,
                duration: animationDuration
            ) { finished in
                transitionContext.completeTransition(finished)
            }
        }
    }
    
    private func createDummyImageView(frame: CGRect, image: UIImage? = nil) -> UIImageView {
        let iv = UIImageView(frame: frame)
        iv.clipsToBounds = true
        iv.alpha = 1.0
        iv.image = image
        return iv
    }
    
    private func presentAnimation(
        transitionView: UIView,
        controller: UIViewController,
        duration: TimeInterval,
        completed: @escaping((Bool) -> Void)
    ) {
        
        guard
            let transitionVC = controller as? ImageViewerTransitionViewControllerConvertible,
            let sourceView = transitionVC.sourceView
        else { return }
        
        sourceView.alpha = 0.0
        controller.view.alpha = 0.0
        
        transitionView.addSubview(controller.view)
        transitionVC.targetView?.alpha = 0.0
        
        let dummyImageView = createDummyImageView(frame: sourceView.frameRelativeToWindow(), image: sourceView.image)
        dummyImageView.contentMode = .scaleAspectFit
        dummyImageView.layer.cornerRadius = sourceView.layer.cornerRadius
        transitionView.addSubview(dummyImageView)
        
        UIView.animate(withDuration: duration, animations: {
            dummyImageView.frame = transitionView.frame
            controller.view.alpha = 1.0
        }) { finished in
            transitionVC.targetView?.alpha = 1.0
            dummyImageView.removeFromSuperview()
            completed(finished)
        }
    }
    
    private func dismissAnimation(
        transitionView: UIView,
        controller: UIViewController,
        duration: TimeInterval,
        completed: @escaping((Bool) -> Void)
    ) {
        
        guard
            let transitionVC = controller as? ImageViewerTransitionViewControllerConvertible
        else { return }
        
        let sourceView = transitionVC.sourceView
        let targetView = transitionVC.targetView
        
        let dummyImageView = createDummyImageView(frame: targetView?.frameRelativeToWindow() ?? UIScreen.main.bounds, image: targetView?.image)
        transitionView.addSubview(dummyImageView)
        targetView?.isHidden = true
        
        controller.view.alpha = 1.0
        UIView.animate(withDuration: duration, animations: {
            if let sourceView = sourceView {
                // return to original position
                dummyImageView.frame = sourceView.frameRelativeToWindow()
                dummyImageView.layer.cornerRadius = sourceView.layer.cornerRadius
            } else {
                // just disappear
                dummyImageView.alpha = 0.0
            }
            controller.view.alpha = 0.0
        }) { finished in
            sourceView?.alpha = 1.0
            controller.view.removeFromSuperview()
            completed(finished)
        }
    }
}

final class ImageViewerTransitionPresentationController: UIPresentationController {
    
    override var frameOfPresentedViewInContainerView: CGRect {
        var frame: CGRect = .zero
        frame.size = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerView!.bounds.size)
        return frame
    }
    
    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
}

final class ImageViewerTransitionPresentationManager: NSObject {
    
}

// MARK: - UIViewControllerTransitioningDelegate
extension ImageViewerTransitionPresentationManager: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        ImageViewerTransitionPresentationController(
            presentedViewController: presented,
            presenting: presenting
        )
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        ImageViewerTransitionPresentationAnimator(isPresenting: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        ImageViewerTransitionPresentationAnimator(isPresenting: false)
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension ImageViewerTransitionPresentationManager: UIAdaptivePresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        .none
    }
    
    func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        nil
    }
}
