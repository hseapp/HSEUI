import UIKit
import HSEUI

public extension UIViewController {
    
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
        CustomNavigationController.setupNavBar(bar, line: line)
        bar.items = [navigationItem]
        view.addSubview(bar)
        bar.stickToSuperviewEdges([.top, .left, .right])
        
        if navigationItem.searchController != nil {
            barHeight += 50
        }
        additionalSafeAreaInsets.top = barHeight
    }
    
}
