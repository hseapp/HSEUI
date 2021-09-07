import UIKit

class BaseCollectionView: UICollectionView, BaseCollectionViewProtocol {
    
    private var contentSizeChanged: (() -> ())?

    private var listeners: [EventListener?] = []
    
    public var collectionDataSource: CollectionDataSource? {
        didSet {
            self.dataSource = collectionDataSource?.dataSource as? UICollectionViewDataSource
        }
    }
    
    override var contentSize: CGSize {
        didSet {
            if oldValue != contentSize {
                contentSizeChanged?()
            }
        }
    }

    init(layoutConfigurator: ((UICollectionViewFlowLayout) -> (UICollectionViewFlowLayout))? = nil) {
        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .vertical
        flow.estimatedItemSize = CGSize(width: 10, height: 10)
        flow.itemSize = UICollectionViewFlowLayout.automaticSize
        flow.minimumLineSpacing = 0
        flow.minimumInteritemSpacing = 0
        super.init(frame: UIScreen.main.bounds, collectionViewLayout: layoutConfigurator?(flow) ?? flow)

        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        backgroundColor = .clear
        allowsSelection = false
        contentInset = .zero
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(to viewModel: CollectionViewModelProtocol?) {
        listeners = []
        listeners.append(viewModel?.setCellVisible.listen { [weak self] (indexPath: IndexPath) in
            guard let self = self else { return }
            guard let flow = self.collectionViewLayout as? UICollectionViewFlowLayout else { return }
            if flow.scrollDirection == .horizontal {
                self.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            } else {
                self.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
            }
        })
        listeners.append(viewModel?.setCellVisible.listen { [weak self] in
            guard let self = self else { return }
            guard let flow = self.collectionViewLayout as? UICollectionViewFlowLayout else { return }
            
            guard let cell = self.visibleCells.min(by: { (cell1, cell2) -> Bool in
                return cell1.frame.origin.distance(to: self.contentOffset) < cell2.frame.origin.distance(to: self.contentOffset)
            }) else { return }
            guard let indexPath = self.indexPath(for: cell) else { return }
            if flow.scrollDirection == .horizontal {
                self.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            } else {
                self.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
            }
        })
        delegate = viewModel as? UICollectionViewDelegate
        contentSizeChanged = { [weak self] in
            guard let self = self else { return }
            viewModel?.contentSizeChanged.raise(data: self.contentSize)
        }
    }
    
    func insertSections(_ sections: IndexSet, with animation: UITableView.RowAnimation) {
        insertSections(sections)
    }
    
    func deleteSections(_ sections: IndexSet, with animation: UITableView.RowAnimation) {
        deleteSections(sections)
    }
    
    func insertItems(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        insertItems(at: indexPaths)
    }
    
    func deleteItems(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        deleteItems(at: indexPaths)
    }
    
    func scrollToTop() {
        scrollToItem(at: .init(row: 0, section: 0), at: .top, animated: true)
    }
    
    func setEditing(_ editing: Bool, animated: Bool) {
        // this method is not supported in collection view
    }
    
    func reloadItems(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        reloadItems(at: indexPaths)
    }
    
    func reloadSections(_ sections: [Int], with animation: UITableView.RowAnimation) {
        reloadSections(IndexSet(sections))
    }

}

fileprivate extension CGPoint {
    
    func distance(to other: CGPoint) -> CGFloat {
        return sqrt((x - other.x) * (x - other.x) + (y - other.y) * (y - other.y))
    }
    
}
