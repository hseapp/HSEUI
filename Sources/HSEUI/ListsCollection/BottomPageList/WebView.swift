import UIKit
import WebKit

extension ListsCollection {
    
    class WebView: CellView {
        
        private let collectionView: CollectionView = .init(type: .web)
        
        override func commonInit() {
            backgroundColor = .clear
            
            addSubview(collectionView)
            collectionView.stickToSuperviewEdges(.all)
        }
        
        override func safeAreaInsetsDidChange() {
            super.safeAreaInsetsDidChange()
            collectionView.additionalSafeAreaInsets.top = findSuperview(ListsCollectionView.self)?.safeAreaInsets.top ?? 0
        }
        
        func reload(with viewModel: CollectionViewModelProtocol?, animated: Bool = false) {
            collectionView.reload(with: viewModel, animated: animated)
        }
        
    }
    
}
