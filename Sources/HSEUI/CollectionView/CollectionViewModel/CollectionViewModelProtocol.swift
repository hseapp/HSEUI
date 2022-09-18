import Foundation

public protocol CollectionViewModelProtocol: NSObject {
    var sections: [SectionViewModel] { set get }
    var whenStoppedCallback: Action? { set get }
    var isScrolling: Bool { get }
    var setCellVisible: Event { get }
    
    func deselectAllCells()
    func copy() -> CollectionViewModelProtocol
}
