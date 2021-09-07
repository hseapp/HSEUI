import UIKit

extension UICollectionView {
    
    enum ElementKind {
        case header, footer, cell
    }
    
    func register<T: UIView>(_ type: T.Type, kind: ElementKind = .cell, reuseId: String) {
        switch kind {
        case .cell:
            return register(BaseCollectionViewCell<T>.self, forCellWithReuseIdentifier: reuseId)
        case .header:
            return register(BaseCollectionReusableView<T>.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: reuseId)
        case .footer:
            return register(BaseCollectionReusableView<T>.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: reuseId)
        }
    }
    
    func dequeue<T: UIView>(_ type: T.Type, for indexPath: IndexPath, reuseId: String) -> BaseCollectionViewCell<T> {
        dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as! BaseCollectionViewCell<T>
    }
    
    func dequeue<T: UIView>(_ type: T.Type, for indexPath: IndexPath, kind: ElementKind, reuseId: String) -> BaseCollectionReusableView<T> {
        switch kind {
        case .cell:
            fatalError("Only header and footer can be dequeued with parameter kind")
        case .header:
            return dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: reuseId, for: indexPath) as! BaseCollectionReusableView<T>
        case .footer:
            return dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: reuseId, for: indexPath) as! BaseCollectionReusableView<T>
        }
    }
    
}

