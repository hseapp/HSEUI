import UIKit

final class CustomCollectionCell<T>: NSObject where T: UIView {
    
    // MARK: - Properties
    
    weak var currentCellViewModel: CellViewModel?
    
    var baseCellView: UIView {
        return view
    }
    
    private var view: T
    
    // MARK: - Init
    
    init(view: T) {
        self.view = view
        self.view.translatesAutoresizingMaskIntoConstraints = false
        super.init()
    }
    
}

// MARK: - Protocol BaseCellProtocol

extension CustomCollectionCell: BaseCellProtocol {
    
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
