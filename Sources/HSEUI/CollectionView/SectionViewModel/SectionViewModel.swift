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
    
    public var features: Set<SectionViewModelFeatures> {
        didSet { applyFeatures() }
    }
    
    // MARK: - Init
    
    public init(cells: [CellViewModel] = [],
                header: CellViewModel? = nil,
                footer: CellViewModel? = nil,
                features: Set<SectionViewModelFeatures> = []) {
        
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
                                footer: footer,
                                features: features)
    }
    
    // MARK: - Private Methods
    
    private func applyFeatures() {
        guard features.contains(.roundTopCorners) || features.contains(.roundBottomCorners) else { return }
        
        for cell in cells {
            cell.features.remove(.roundTopCorners)
            cell.features.remove(.roundBottomCorners)
        }
        
        if features.contains(.roundTopCorners) {
            let firstCell = cells.first(where: { !($0 is FooterViewModel) })
            firstCell?.features.insert(.roundTopCorners)
        }
        
        if features.contains(.roundTopCorners) {
            let lastCell = cells.last(where: { !($0 is FooterViewModel) })
            lastCell?.features.insert(.roundBottomCorners)
        }
    }

}
