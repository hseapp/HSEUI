//
//  BS.swift
//  HSEUIExample
//
//  Created by Matvey Kavtorov on 9/30/21.
//

import UIKit
import HSBottomSheet
import HSEUI

extension UIViewController {
    
    func showControllerAsBottomsheet(
        _ vc: UIViewController,
        title: String? = nil,
        sizes: [SheetSize] = [.fullScreen],
        hideHandleView: Bool = false,
        dismissable: Bool = true,
        sender: UIViewController? = nil,
        backgroundColor: UIColor? = nil,
        withCloseButton: Bool = false,
        withCancelButton: Bool = false,
        hideNavigationBarSeparator: Bool = true,
        offset: CGFloat = 32,
        completion: Action? = nil
    ) {
        let wrapper = BottomSheetOffsetViewController(
            viewController: vc,
            title: title,
            offset: hideHandleView ? 0 : offset,
            withCloseButton: withCloseButton,
            withCancelButton: withCancelButton,
            backgroundColor: backgroundColor,
            hideNavigationBarSeparator: hideNavigationBarSeparator
        )
        
        let bs = HSBottomSheet(controller: wrapper, sizes: sizes)
        bs.dismissOnBackgroundTap = true
        bs.handleTopEdgeInset = 12
        bs.handleSize = CGSize(width: 36, height: 5)
        bs.handleColor = Color.Base.secondary
        bs.overlayColor = Color.Base.black.withAlphaComponent(0.1)
        bs.topCornersRadius = 16
        bs.extendBackgroundBehindHandle = false
        bs.dismissable = dismissable
        bs.handleView.isHidden = hideHandleView
//        bs.childViewInset.top = hideHandleView ? 0 : offset
        bs.modalTransitionStyle = .crossDissolve
        bs.didDismiss = { _ in completion?() }
//        bs.useDynamicHeight = true
        
//        if let collection = vc.view.findChildren(CollectionView.self).first,
//           collection.type == .list,
//           let scroll = collection.findChildren(UIScrollView.self).first {
//            bs.childScrollView = scroll
//        }
        
        let vc = sender ?? UIApplication.shared.keyWindow?.rootViewController?.topController(excludeBottomSheet: false)
        vc?.present(bs, animated: true, completion: nil)
//        bottomSheetStack.push(bs)
    }
    
    func topController(excludeBottomSheet: Bool = true) -> UIViewController {
        if let child = self.presentedViewController, (!excludeBottomSheet && (child is HSBottomSheet)) {
            return child.topController()
        } else if let tabBar = self as? UITabBarController {
            return tabBar.viewControllers?[tabBar.selectedIndex].topController() ?? self
        } else if let split = self as? UISplitViewController {
            return split.viewControllers.last?.topController() ?? self
        } else {
            return self
        }
    }
    
}

fileprivate final class BottomSheetOffsetViewController: UIViewController {
    
    fileprivate var child: UIViewController
    
    private var backgroundColor: UIColor?
    
    private var navigationBar: UINavigationBar? {
        view.subviews.first(where: { $0 is UINavigationBar }) as? UINavigationBar
    }
    
    private var offset: CGFloat
    
    private var hideNavigationBarSeparator: Bool
    
    init(
        viewController: UIViewController,
        title: String?,
        offset: CGFloat,
        withCloseButton: Bool,
        withCancelButton: Bool,
        backgroundColor: UIColor? = nil,
        hideNavigationBarSeparator: Bool = false
    ) {
        self.child = viewController
        self.backgroundColor = backgroundColor
        self.offset = offset
        self.hideNavigationBarSeparator = hideNavigationBarSeparator
        
        super.init(nibName: nil, bundle: nil)
        
        guard !(viewController is UINavigationController) else { return }
        
        self.title = title ?? child.title
        
        if withCloseButton {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "close"), style: .plain, target: self, action: #selector(close))
        } else if withCancelButton {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "common.undo", style: .plain, target: self, action: #selector(close))
            navigationItem.leftBarButtonItem?.tintColor = Color.Base.brandTint
        } else {
            if let leftButtons = child.navigationItem.leftBarButtonItems {
                navigationItem.leftBarButtonItems = leftButtons
            }
            if let rightButtons = child.navigationItem.rightBarButtonItems {
                navigationItem.rightBarButtonItems = rightButtons
            }
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addCustomNavigationBarIfNeeded(isLineHidden: hideNavigationBarSeparator)
        
        view.backgroundColor = backgroundColor ?? Color.Base.mainBackground
        
        addChild(child)
        view.addSubview(child.view)
        child.view.stickToSuperviewEdges([.left, .right, .bottom])
        child.view.safeTop(offset)
    }
    
    @objc private func close() {
//        Navigator.main.closeSheet()
    }
    
    func addCustomNavigationBarIfNeeded(isLineHidden: Bool = false) {
        guard navigationItem.title?.isEmpty == false || navigationItem.leftBarButtonItems != nil || navigationItem.rightBarButtonItems != nil || navigationItem.searchController != nil else { return }
        guard navigationController == nil else { return }
        guard !(self is UINavigationController) else { return }
        guard view.subviews.filter({ $0 is UINavigationBar }).isEmpty else { return }
        
        var barHeight: CGFloat = 50
        
        let bar = UINavigationBar()
        let line = UIView()
        if isLineHidden {
            line.isHidden = true
        }
        line.backgroundColor = Color.Base.separator
        Self.setupNavBar(bar, line: line)
        bar.items = [navigationItem]
        view.addSubview(bar)
        bar.stickToSuperviewEdges([.top, .left, .right])
        
        if navigationItem.searchController != nil {
            barHeight += 50
        }
        additionalSafeAreaInsets.top = barHeight
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
    
}
