import UIKit

public protocol BaseCellProtocol: AnyObject {
    var baseCellView: UIView { get }
    var currentCellViewModel: CellViewModel? { set get }
    
    func updateConfigurator<C: CellViewConfiguratorProtocol>(with configurator: C)
    
    func setSelected(_ value: Bool)
    func setSelectionBlock(_ block: @escaping (Bool) -> Bool)
    
    func setWidth(_ value: CGFloat)
    func setHeight(_ value: CGFloat)
    
    func apply<U: UIView>(_ block: (U) -> ())
    func getCellView() -> UIView
}

extension BaseCellProtocol {
    
    // Need to set up viewModel because every baseCell must have 
    // only one CellViewModel at one time, otherwise there are
    // some bugs with cells selection during cells reuse
    func setViewModel(_ viewModel: CellViewModel) {
        currentCellViewModel?.baseCell = nil
        currentCellViewModel = viewModel
    }
    
}
