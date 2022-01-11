import UIKit
import HSEUI

public class MenuOptionsCollectionViewModel: CellViewModel {

    public init(viewModel: CollectionViewModel) {
        super.init(view: MenuOptionsCollectionView.self, configureView: { view in
            view.collectionView.reload(with: viewModel)
        })
    }

}

public class MenuOptionsCollectionView: CellView {
    
    public var collectionHeightConstraint: NSLayoutConstraint?

    public let collectionView: CollectionView = {
        let cv = CollectionView(type: .grid) { _ -> (UICollectionViewFlowLayout) in
            let layout = UICollectionViewFlowLayout()
            layout.sectionInset = .init(top: 0, left: 12, bottom: 0, right: 12)
            layout.minimumLineSpacing = 8
            layout.minimumInteritemSpacing = 8
            layout.estimatedItemSize = CGSize(width: 32, height: 20)
            layout.scrollDirection = .horizontal
            return layout
        }
        return cv
    }()
    
    public let separator: SeparatorView = .init()
    
    public let blur = UIVisualEffectView(effect: UIBlurEffect(style: .defaultHSEUI))

    public override func commonInit() {
        addSubview(blur)
        blur.stickToSuperviewEdges(.all)
        
        addSubview(collectionView)
        collectionView.stickToSuperviewEdges([.left, .top, .right])
        collectionView.backgroundColor = .clear
        backgroundColor = .clear
        collectionHeightConstraint = collectionView.height(48)
        
        addSubview(separator)
        separator.top(to: collectionView)
        separator.stickToSuperviewEdges([.left, .bottom, .right])
    }
    
    public func updateBlur(alpha: CGFloat) {
        let boundedAlpha: CGFloat = min(max(alpha, 0), 1)
        blur.alpha = boundedAlpha
        collectionView.backgroundColor = Color.Base.mainBackground.withAlphaComponent(1 - boundedAlpha)
    }

}
