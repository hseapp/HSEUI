import UIKit
import HSEUI

// MARK: - separator for cells
extension Array where Element: CellViewModel {

    public func separated(insets: UIEdgeInsets = .init(top: 0, left: 12, bottom: 0, right: 12), skipHeaders: Bool = true) -> [CellViewModel] {
        var result: [CellViewModel] = []
        for cell in self {
            result.append(cell)
            if skipHeaders, let _ = cell as? HeaderViewModel {} else {
                result.append(SeparatorViewModel(insets: insets))
            }
        }
        if result.count > 0 { result.removeLast() }
        return result
    }

    public func spaced(spacing: CGFloat = 8) -> [CellViewModel] {
        var result: [CellViewModel] = []
        for cell in self {
            result.append(cell)
            if let _ = cell as? HeaderViewModel {} else {
                result.append(PaddingViewModel(padding: spacing))
            }
        }
        if result.count > 0 { result.removeLast() }
        return result
    }

}
