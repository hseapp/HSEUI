import UIKit

public protocol CellViewConfiguratorProtocol {
    associatedtype T: UIView
    var configureView: ((T) -> Void)? { set get }
    var tapCallback: Action? { set get }
    var useChevron: Bool? { set get }
}
