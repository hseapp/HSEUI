import UIKit

final class BaseCollectionViewCell<T>: UICollectionViewCell where T: UIView {
    
    // MARK: - Properties
    
    weak var currentCellViewModel: CellViewModel?
    
    var baseCellView: UIView {
        return self
    }
    
    private var view: T
    
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
        backgroundColor = .clear
        
        contentView.removeFromSuperview()
        
        addSubview(view)
        view.stickToSuperviewEdges([.left, .top])
        
        let bottomConstraint = view.bottom()
        bottomConstraint.priority = UILayoutPriority(999)
        let trailingConstraint = view.trailing()
        trailingConstraint.priority = UILayoutPriority(999)
    }
    
}

// MARK: - Protocol BaseCellProtocol

extension BaseCollectionViewCell: BaseCellProtocol {
    
    func updateConfigurator<C>(with configurator: C) where C : CellViewConfiguratorProtocol {
        if view as? C.T != nil {
            configurator.configureView?(view as! C.T)
            (view as? CellView)?.useChevron = configurator.useChevron ?? (configurator.tapCallback != nil)
            (view as? CellView)?.configureTap(callback: configurator.tapCallback)
        }
    }
    
    func setSelected(_ value: Bool) {
        (view as? CellView)?.setSelected(selected: value, animated: true)
    }
    
    func setSelectionBlock(_ block: @escaping (Bool) -> Bool) {
        (view as? CellView)?.configureSelectionCallback(callback: block)
    }
    
    func setWidth(_ value: CGFloat) {
        (view as? CellView)?.widthConstant = value
        (view as? CellView)?.widthConstraint?.priority = .required
    }
    
    func setHeight(_ value: CGFloat) {
        (view as? CellView)?.heightConstant = value
        (view as? CellView)?.heightConstraint?.priority = .required
    }
    
    func apply<U: UIView>(_ block: (U) -> ()) {
        if (view as? U) != nil {
            block(view as! U)
        }
    }
    
    func getCellView() -> UIView {
        return view
    }
    
}
