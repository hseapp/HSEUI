import UIKit
import HSEUI

extension UIViewController {
    
    public func showHSELoader() {
        showOverflow(HSELoader())
    }

    public func showOverflow(
        _ overflow: UIView,
        allowUserInteraction: Bool = false,
        top: UIView? = nil,
        offset: CGFloat = 0
    ) {
        removeOverflow()
        
        view.subviews.forEach { view in
            view.isUserInteractionEnabled = allowUserInteraction
        }
        
        overflow.tag = ViewTag.overflowTag
        self.view.addSubview(overflow)
        if let top = top {
            overflow.top(offset, to: top)
            overflow.centerHorizontally()
        } else {
            let yOffset = UIScreen.main.bounds.height / 15
            overflow.placeInCenter(offset: .init(dx: 0, dy: -yOffset))
        }
        OverflowTimeManager.main.registerOverflow(for: self)
        UIAccessibility.post(notification: .screenChanged, argument: nil)
    }
    
    public func showSkeletonOrLoader() {
        if let skeleton = SkeletonManager.main.getSkeleton(for: self) {
            removeOverflow()
            skeleton.tag = ViewTag.overflowTag
            self.view.addSubview(skeleton)
            skeleton.stickToSuperviewSafeEdges([.left, .right])
            
            if (self as? CollectionViewController)?.collectionView is ListsCollectionView {
                skeleton.stickToSuperviewEdges([.top, .bottom])
            } else {
                skeleton.stickToSuperviewSafeEdges([.top, .bottom])
            }
            
            OverflowTimeManager.main.registerOverflow(for: self)
        } else {
            showOverflow(SkeletonLoader())
        }
    }

    public func removeOverflow() {
        guard let v = self.view.viewWithTag(ViewTag.overflowTag) else { return }
        UIAccessibility.post(notification: .screenChanged, argument: nil)
        
        view.subviews.forEach { view in
            view.isUserInteractionEnabled = true
        }
        
        let readSkeleton = v.classForCoder == SkeletonLoader.classForCoder() || v.classForCoder == SkeletonView.classForCoder()
        let block = {
            if readSkeleton {
                UIView.animate(withDuration: 0.5) {
                    v.alpha = 0
                } completion: { [weak self] _ in
                    guard let self = self else { return }
                    v.removeFromSuperview()
                    v.alpha = 1
                    SkeletonManager.main.readSkeleton(for: self)
                }
            } else {
                v.removeFromSuperview()
            }
        }
        let time = OverflowTimeManager.main.overflowTimeRemaining(for: self)
        if time > 0 {
            mainQueue(delay: time, block: block)
        } else {
            block()
        }
    }

    public func showOrHideOverflow() {
        self.view.viewWithTag(ViewTag.overflowTag)?.isHidden.toggle()
    }

}

typealias SkeletonLoader = HSELoader


fileprivate class OverflowTimeManager {
    
    var minimumOverflowTime: TimeInterval = 0.2
    
    static let main = OverflowTimeManager()
    
    private var overflowDates: [Int: Date] = [:]
    
    func registerOverflow(for vc: UIViewController) {
        overflowDates[vc.hashValue] = Date()
    }
    
    func overflowTimeRemaining(for vc: UIViewController) -> TimeInterval {
        guard let date = overflowDates[vc.hashValue] else { return 0 }
        return max(minimumOverflowTime - Date().timeIntervalSince(date), 0)
    }
    
    
}
