import UIKit

final class BaseTableViewHeaderFooterCell<T>: UITableViewHeaderFooterView where T: UIView {
    
    // MARK: - Properties
    
    weak var currentCellViewModel: CellViewModel?
    
    var baseCellView: UIView {
        return self
    }
    
    private var view: T
    
    // MARK: - Init
    
    override init(reuseIdentifier: String?) {
        view = T.init()
        super.init(reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    private func commonInit() {
        backgroundView?.backgroundColor = .clear
        
        contentView.addSubview(view)
        view.stickToSuperviewEdges([.left, .top, .right])
        
        let bottomConstraint = view.bottom()
        bottomConstraint.priority = UILayoutPriority(999)
    }
    
}

// MARK: - Protocol BaseCellProtocol

extension BaseTableViewHeaderFooterCell: BaseCellProtocol {
    
    func updateConfigurator<C>(with configurator: C) where C : CellViewConfiguratorProtocol {
        if view as? C.T != nil {
            configurator.configureView?(view as! C.T)
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
