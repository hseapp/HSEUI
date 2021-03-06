open class SectionViewModel: SectionViewModelProtocol {
    
    public let id: Int = Nonce()

    public var cells: [CellViewModelProtocol]
    public var header: CellViewModelProtocol?
    public var footer: CellViewModelProtocol?

    public init(
        cells: [CellViewModelProtocol] = [],
        header: CellViewModelProtocol? = nil,
        footer: CellViewModelProtocol? = nil
    ) {
        self.cells = cells
        self.header = header
        self.footer = footer
    }

    public func copy() -> SectionViewModelProtocol {
        return SectionViewModel(cells: cells, header: header, footer: footer)
    }

}
