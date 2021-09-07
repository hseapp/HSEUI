import UIKit

public protocol CellViewProtocol: UIView {    
    var heightConstraint: NSLayoutConstraint? { set get }
    var heightConstant: CGFloat? { set get }
    var widthConstraint: NSLayoutConstraint? { set get }
    var widthConstant: CGFloat? { set get }
    var useChevron: Bool { set get }
    
    func configureTap(callback: Action?)
    func setSelected(selected: Bool, animated: Bool)
    func configureSelectionCallback(callback: @escaping (Bool) -> Bool)
}
