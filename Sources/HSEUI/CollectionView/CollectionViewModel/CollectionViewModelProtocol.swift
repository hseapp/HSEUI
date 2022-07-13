import Foundation

public protocol CollectionViewModelProtocol: NSObject {
    var sections: [SectionViewModelProtocol] { set get }
    var whenStoppedCallback: Action? { set get }
    var isScrolling: Bool { get }
    var setCellVisible: Event { get }
    var contentSizeChanged: Event { get }
    
    func isEqual(to viewModel: CollectionViewModelProtocol?) -> Bool
    func deselectAllCells()
    func copy() -> CollectionViewModelProtocol
}
