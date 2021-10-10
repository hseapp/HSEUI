import UIKit
import HSEUI

extension ListsCollection {
    
    class ListView: CellView {
        
        let collectionView: CollectionView = {
            let cv = CollectionView(type: .list)
            cv.backgroundColor = .clear
            return cv
        }()
        
        override func commonInit() {
            backgroundColor = .clear
            
            addSubview(collectionView)
            collectionView.stickToSuperviewEdges(.all)
        }
        
        func reload(with viewModel: CollectionViewModelProtocol?, animated: Bool = false) {
            collectionView.reload(with: viewModel, animated: animated)
        }
        
        override func safeAreaInsetsDidChange() {
            super.safeAreaInsetsDidChange()
            collectionView.additionalSafeAreaInsets.top = findSuperview(ListsCollectionView.self)?.safeAreaInsets.top ?? 0
        }
        
    }
    
}
