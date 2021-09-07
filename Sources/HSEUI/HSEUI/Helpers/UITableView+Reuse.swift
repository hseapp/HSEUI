import UIKit

extension UITableView {
    
    public enum ElementKind {
        case headerFooter, cell
    }
    
    func register<T: UIView>(_ type: T.Type, kind: ElementKind = .cell, reuseId: String) {
        switch kind {
        case .cell:
            self.register(BaseTableViewCell<T>.self, forCellReuseIdentifier: reuseId)
        case .headerFooter:
            self.register(BaseTableViewHeaderFooterCell<T>.self, forHeaderFooterViewReuseIdentifier: reuseId)
        }
    }
    
    func dequeue<T: UIView>(_ type: T.Type, for indexPath: IndexPath, kind: ElementKind = .cell, reuseId: String) -> UIView {
        switch kind {
        case .cell:
            return dequeueReusableCell(withIdentifier: reuseId, for: indexPath) as! BaseTableViewCell<T>
        case .headerFooter:
            return dequeueReusableHeaderFooterView(withIdentifier: reuseId) as! BaseTableViewHeaderFooterCell<T>
        }
    }
    
}
