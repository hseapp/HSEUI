import UIKit

final class BaseCollectionReusableView<T>: UICollectionReusableView where T: UIView {
    
    // MARK: - Properties
    
    private var view: T
    
    var configureView: ((T) -> ())? {
        didSet {
            configureView?(view)
        }
    }
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        view = T.init()
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    private func commonInit() {
        backgroundColor = Color.Base.mainBackground
        
        addSubview(view)
        view.stickToSuperviewEdges([.left, .top])
        
        let bottomConstraint = view.bottom()
        bottomConstraint.priority = UILayoutPriority(999)
        let trailingConstraint = view.trailing()
        trailingConstraint.priority = UILayoutPriority(999)
        
        accessibilityElements = [view]
    }
    
}
