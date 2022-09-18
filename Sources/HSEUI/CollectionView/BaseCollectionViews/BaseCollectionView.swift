import UIKit

final class BaseCollectionView: UICollectionView, BaseCollectionViewProtocol {
    
    // MARK: - Internal Properties
    
    public var collectionDataSource: CollectionDataSource? {
        didSet {
            self.dataSource = collectionDataSource?.dataSource as? UICollectionViewDataSource
        }
    }
    
    // MARK: - Private Properties
    
    private var listeners: [EventListener?] = []
    
    // MARK: - Init

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
    
    // MARK: - Internal Methods

    func bind(to viewModel: CollectionViewModelProtocol?) {
        delegate = viewModel as? UICollectionViewDelegate
        listeners = []
        listeners.append(viewModel?.setCellVisible.listen { [weak self] (indexPath: IndexPath) in
            guard let self = self else { return }
            self.scroll(to: indexPath)
        })
        
        listeners.append(viewModel?.setCellVisible.listen { [weak self] in
            guard let self = self else { return }
            guard let cell = self.visibleCells.min(by: { (cell1, cell2) -> Bool in
                return cell1.frame.origin.distance(to: self.contentOffset) < cell2.frame.origin.distance(to: self.contentOffset)
            }) else { return }
            guard let indexPath = self.indexPath(for: cell) else { return }
            self.scroll(to: indexPath)
        })
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
        if contentOffset != .zero,
           let firstSection = (0..<numberOfSections).first(where: { numberOfItems(inSection: $0) > 0 }) {
            scrollToItem(at: .init(item: 0, section: firstSection), at: .top, animated: true)
        }
    }

    func scroll(to indexPath: IndexPath) {
        guard let flow = self.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        if flow.scrollDirection == .horizontal {
            self.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
        else {
            self.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
        }
    }
    
    func reloadItems(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        reloadItems(at: indexPaths)
    }
    
    func reloadSections(_ sections: [Int], with animation: UITableView.RowAnimation) {
        reloadSections(IndexSet(sections))
    }

}

// MARK: - Private Helpers

private extension CGPoint {
    
    func distance(to other: CGPoint) -> CGFloat {
        return sqrt((x - other.x) * (x - other.x) + (y - other.y) * (y - other.y))
    }
    
}
