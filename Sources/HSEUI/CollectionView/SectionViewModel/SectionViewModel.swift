import Foundation


public enum SectionViewModelFeatures {
    case roundTopCorners
    case roundBottomCorners
}

open class SectionViewModel {
    
    // MARK: - Public Properties
    
    public let id: Int = Nonce()
    
    public var header: CellViewModel?
    public var footer: CellViewModel?
    
    public var cells: [CellViewModel] {
        didSet { applyFeatures() }
    }
    
    public var features: [SectionViewModelFeatures] {
        didSet { applyFeatures() }
    }
    
    // MARK: - Init
    
    public init(cells: [CellViewModel] = [],
                header: CellViewModel? = nil,
                footer: CellViewModel? = nil,
                features: [SectionViewModelFeatures] = []) {
        
        self.cells = cells
        self.header = header
        self.footer = footer
        self.features = features
        
        applyFeatures()
    }
    
    // MARK: - Public Methods

    public func copy() -> SectionViewModel {
        return SectionViewModel(cells: cells,
                                header: header,
                                footer: footer)
    }
    
    // MARK: - Private Methods
    
    private func applyFeatures() {
        for cell in cells {
            cell.features = []
        }
        
        if features.contains(.roundTopCorners) {
            let firstCell = cells.first(where: { !($0 is FooterViewModel) })
            firstCell?.features.append(.roundTopCorners)
        }
        
        if features.contains(.roundTopCorners) {
            let lastCell = cells.last(where: { !($0 is FooterViewModel) })
            lastCell?.features.append(.roundBottomCorners)
        }
    }

}
