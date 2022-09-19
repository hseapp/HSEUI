import Foundation

open class SectionViewModel {
    
    public let id: Int = Nonce()

    public var cells: [CellViewModel]
    public var header: CellViewModel?
    public var footer: CellViewModel?
    
    public init(cells: [CellViewModel] = [],
                header: CellViewModel? = nil,
                footer: CellViewModel? = nil) {
        
        self.cells = cells
        self.header = header
        self.footer = footer
    }

    public func copy() -> SectionViewModel {
        return SectionViewModel(cells: cells, header: header, footer: footer)
    }

}
