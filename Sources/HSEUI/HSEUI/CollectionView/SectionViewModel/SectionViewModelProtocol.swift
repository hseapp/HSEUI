public protocol SectionViewModelProtocol: AnyObject {
    var id: Int { get }
    var cells: [CellViewModelProtocol] { set get }
    var header: CellViewModelProtocol? { set get }
    var footer: CellViewModelProtocol? { set get }
    func copy() -> SectionViewModelProtocol
}
