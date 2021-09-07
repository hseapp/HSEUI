import UIKit

protocol BaseCollectionViewProtocol: UIView {
    var spacing: CGFloat { set get }
    var isScrollEnabled: Bool { set get }
    var collectionDataSource: CollectionDataSource? { set get }
    var contentInset: UIEdgeInsets { set get }
    var adjustedContentInset: UIEdgeInsets { get }
    
    func bind(to viewModel: CollectionViewModelProtocol?)
    func reloadData()
    func insertSections(_ sections: IndexSet, with animation: UITableView.RowAnimation)
    func deleteSections(_ sections: IndexSet, with animation: UITableView.RowAnimation)
    func insertItems(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation)
    func deleteItems(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation)
    func scrollToTop()
    func setEditing(_ editing: Bool, animated: Bool)
    func scrollRectToVisible(_ rect: CGRect, animated: Bool)
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
        assertionFailure("insertSections is not supported here")
    }
    
    func deleteSections(_ sections: IndexSet, with animation: UITableView.RowAnimation) {
        assertionFailure("deleteSections is not supported here")
    }
    
    func insertItems(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        assertionFailure("insertItems is not supported here")
    }
    
    func deleteItems(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        assertionFailure("deleteItems is not supported here")
    }
    
    func scrollToTop() {
        assertionFailure("scrollToTop is not supported in chips")
    }
    
    func setEditing(_ editing: Bool, animated: Bool) {
        assertionFailure("setEditing is not supported in chips")
    }
    
    func scrollRectToVisible(_ rect: CGRect, animated: Bool) {
        assertionFailure("setEditing is not supported in chips")
    }
    
    func reloadItems(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        assertionFailure("This method is not supported")
    }
    
    func reloadSections(_ sections: [Int], with animation: UITableView.RowAnimation) {
        assertionFailure("This method is not supported")
    }
    
    func bind(to viewModel: CollectionViewModelProtocol?) { }
    
    func orientationWillChange(newSize: CGSize) { }
    
    func beginRefreshing() {
        assertionFailure("This method is not supported here")
    }
    
}
