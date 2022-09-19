import UIKit

final class BaseTableViewCell<T>: UITableViewCell where T: UIView {
    
    // MARK: - Properties
    
    private var view: T
    weak var currentCellViewModel: CellViewModel?
    
    var useChevron: Bool = false {
        didSet {
            (view as? CellView)?.useChevron = useChevron
            accessoryType = useChevron ? .disclosureIndicator : .none
        }
    }
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        view = T.init()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        backgroundColor = view.backgroundColor
        
        contentView.addSubview(view)
        view.stickToSuperviewEdges([.left, .top, .right])
        
        let bottomConstraint = view.bottom()
        bottomConstraint.priority = UILayoutPriority(999)
        
        accessibilityElements = [view]
    }

}

// MARK: - Protocol BaseCellProtocol

extension BaseTableViewCell: BaseCellProtocol {
    
    func updateConfigurator<C>(with configurator: C) where C : CellViewConfiguratorProtocol {
        if view as? C.T != nil {
            configurator.configureView?(view as! C.T)
            self.useChevron = configurator.useChevron ?? (configurator.tapCallback != nil)
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
