import UIKit

public protocol BaseCellProtocol: AnyObject {
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
    
    func setViewModel(_ viewModel: CellViewModel) {
        currentCellViewModel?.resetBaseCell()
        currentCellViewModel = viewModel
    }
    
}
