import UIKit

protocol BaseCollectionViewProtocol: UIView {
    var spacing: CGFloat { set get }
    var isScrollEnabled: Bool { set get }
    var collectionDataSource: CollectionDataSource? { set get }
    var contentInset: UIEdgeInsets { set get }
    var adjustedContentInset: UIEdgeInsets { get }
    var contentSize: CGSize { get }
    
    func bind(to viewModel: CollectionViewModelProtocol?)
    func reloadData()
    func insertSections(_ sections: IndexSet, with animation: UITableView.RowAnimation)
    func deleteSections(_ sections: IndexSet, with animation: UITableView.RowAnimation)
    func insertItems(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation)
    func deleteItems(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation)
    func scrollToTop()
    func scroll(to indexPath: IndexPath)
    func setEditing(_ editing: Bool, animated: Bool)
    func reloadItems(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation)
    func reloadSections(_ sections: [Int], with animation: UITableView.RowAnimation)
    func orientationWillChange(newSize: CGSize)
    func beginRefreshing()
}

extension BaseCollectionViewProtocol {
    
    var spacing: CGFloat {
        set {
            fatalError("spacing is not supported in this type")
        }
        get {
            return 0
        }
    }
    
    var adjustedContentInset: UIEdgeInsets {
        return .zero
    }
    
    var isScrollEnabled: Bool {
        get {
            return false
        }
        set {
            if newValue {
                assertionFailure("set isScrollEnabled is not supported in chips")
            }
        }
    }
    
    func insertSections(_ sections: IndexSet, with animation: UITableView.RowAnimation) {
        assertionFailure("insertSections is not implemented for \(String(describing: self))")
    }
    
    func deleteSections(_ sections: IndexSet, with animation: UITableView.RowAnimation) {
        assertionFailure("deleteSections is not implemented for \(String(describing: self))")
    }
    
    func insertItems(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        assertionFailure("insertItems is not implemented for \(String(describing: self))")
    }
    
    func deleteItems(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        assertionFailure("deleteItems is not implemented for \(String(describing: self))")
    }
    
    func scrollToTop() {
        assertionFailure("scrollToTop is not implemented for \(String(describing: self))")
    }

    func scroll(to indexPath: IndexPath) {
        assertionFailure("scrollTo is not implemented for \(String(describing: self))")
    }
    
    func setEditing(_ editing: Bool, animated: Bool) {
        assertionFailure("setEditing is not implemented for \(String(describing: self))")
    }
    
    func reloadItems(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        assertionFailure("This method is not implemented for \(String(describing: self))")
    }
    
    func reloadSections(_ sections: [Int], with animation: UITableView.RowAnimation) {
        assertionFailure("This method is not implemented for \(String(describing: self))")
    }
    
    func bind(to viewModel: CollectionViewModelProtocol?) { }
    
    func orientationWillChange(newSize: CGSize) { }
    
    func beginRefreshing() {
        assertionFailure("This method is implemented for \(String(describing: self))")
    }
    
}
