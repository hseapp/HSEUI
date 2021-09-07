import Foundation

public enum SelectionStyle {
    case none
    case tap
    case single
    case multiple
    case picker
    case sectionPicker([Int]? = nil)
}

extension SelectionStyle {
    
    func shouldSelectCell(
        row: Int,
        section: Int,
        selected: Bool,
        selectedCells: inout Set<IndexPath>,
        deselectAllExcept: (Int, Int) -> Void,
        getCell: (IndexPath) -> CellViewModelProtocol?
    ) -> Bool {
        switch self {
        case .none:
            return false
        case .multiple:
            if selected {
                selectedCells.insert(IndexPath(row: row, section: section))
            } else {
                selectedCells.remove(IndexPath(row: row, section: section))
            }
            return selected
        case .single:
            if !selected { return false }
            deselectAllExcept(row, section)
            selectedCells = [IndexPath(row: row, section: section)]
            return selected
        case .tap:
            if !selected { return false }
            deselectAllExcept(row, section)
            selectedCells = [IndexPath(row: row, section: section)]
            let cell = getCell(IndexPath(row: row, section: section))
            mainQueue(delay: 0.3) {
                cell?.isSelected = false
            }
            return selected
        case .picker:
            if !selected {
                if selectedCells.contains(IndexPath(row: row, section: section)) {
                    return true
                }
                return false
            }
            let indexPath = selectedCells.first
            selectedCells = [IndexPath(row: row, section: section)]
            if let indexPath = indexPath { getCell(indexPath)?.isSelected = false }
            return selected
        case .sectionPicker(let sections):
            if let sections = sections, !sections.contains(section) {
                return false
            }
            if !selected {
                if selectedCells.contains(IndexPath(row: row, section: section)) {
                    return true
                }
                return false
            }
            let indexPaths = selectedCells.filter { $0.section == section }
            indexPaths.forEach {
                selectedCells.remove($0)
            }
            indexPaths.forEach {
                getCell($0)?.isSelected = false
            }
            selectedCells.insert(IndexPath(row: row, section: section))
            return selected
        }
    }
    
}
