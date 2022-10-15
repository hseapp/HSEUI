import UIKit

public class MenuOptionsCollectionView: CellView {
    
    public var collectionHeightConstraint: NSLayoutConstraint?
    public let blur = UIVisualEffectView(effect: UIBlurEffect(style: .defaultHSEUI))
    
    public let separator: SeparatorView = .init()
    
    public var cornerRadiusTopNormalisedValue: CGFloat = 0 {
        didSet {
            let cropped = min(1, max(0, cornerRadiusTopNormalisedValue))
            layer.cornerRadius = 12 * cropped
            layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        }
    }
    
    public let collectionView: CollectionView = {
        let collectionView = CollectionView(type: .grid) { _ -> (UICollectionViewFlowLayout) in
            let layout = UICollectionViewFlowLayout()
            layout.sectionInset = .init(top: 0, left: 12, bottom: 0, right: 12)
            layout.minimumLineSpacing = 8
            layout.minimumInteritemSpacing = 8
            layout.estimatedItemSize = CGSize(width: 32, height: 20)
            layout.scrollDirection = .horizontal
            return layout
        }
        
        return collectionView
    }()

    public override func commonInit() {
        clipsToBounds = true
        backgroundColor = Color.Base.mainBackground
        
        addSubview(blur)
        blur.stickToSuperviewEdges(.all)
        
        addSubview(collectionView)
        collectionView.stickToSuperviewEdges([.left, .top, .right])
        collectionView.backgroundColor = .clear
        collectionHeightConstraint = collectionView.height(48)
        
        addSubview(separator)
        separator.top(to: collectionView)
        separator.stickToSuperviewEdges([.left, .bottom, .right])
    }
    
    public func updateBlur(alpha: CGFloat) {
        let boundedAlpha: CGFloat = min(max(alpha, 0), 1)
        blur.alpha = boundedAlpha
        collectionView.backgroundColor = backgroundColor?.withAlphaComponent(1 - boundedAlpha)
    }

}
