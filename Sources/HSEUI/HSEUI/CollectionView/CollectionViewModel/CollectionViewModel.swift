import UIKit

open class CollectionViewModel: NSObject, CollectionViewModelProtocol {

    // MARK: - private properties
    private var selectionStyle: SelectionStyle = .none

    private var _selectedCells: Set<IndexPath> = []

    // MARK: - internal properties
    public var sections: [SectionViewModelProtocol] {
        didSet {
            updateSelectionBlocks()
        }
    }

    public var whenStoppedCallback: Action?

    public var contentOffsetChanged = Event.new()
    
    public var contentSizeChanged = Event.new()
    
    public var setCellVisible = Event.new()
    
    public var isScrolling: Bool = false {
        didSet {
            if isScrolling == false, isScrolling != oldValue {
                whenStoppedCallback?()
            }
        }
    }

    public var selectedCells: [CellViewModelProtocol] {
        return _selectedCells.compactMap { self.cell(at: $0) }
    }

    // MARK: - init
    public init(sections: [SectionViewModelProtocol] = [], selectionStyle: SelectionStyle = .none) {
        self.sections = sections
        self.selectionStyle = selectionStyle
        super.init()
        self.updateSelectionBlocks()
    }

    public init(section: SectionViewModelProtocol, selectionStyle: SelectionStyle = .none) {
        self.sections = [section]
        self.selectionStyle = selectionStyle
        super.init()
        self.updateSelectionBlocks()
    }

    public init(cells: [CellViewModelProtocol], selectionStyle: SelectionStyle = .none) {
        self.sections = [SectionViewModel(cells: cells)]
        self.selectionStyle = selectionStyle
        super.init()
        self.updateSelectionBlocks()
    }

    public init(cell: CellViewModelProtocol) {
        self.sections = [SectionViewModel(cells: [cell])]
        self.selectionStyle = .none
        super.init()
        self.updateSelectionBlocks()
    }

    // MARK: - update selection blocks
    private func updateSelectionBlocks() {
        sections.enumerated().forEach { j, section in
            section.cells.enumerated().forEach { i, cell in
                cell.selectionBlock = { [weak self] selected in
                    guard let self = self else { return false }
                    switch self.selectionStyle {
                    case .none:
                        return false
                    case .multiple:
                        if selected {
                            self._selectedCells.insert(IndexPath(row: i, section: j))
                        } else {
                            self._selectedCells.remove(IndexPath(row: i, section: j))
                        }
                        return selected
                    case .single:
                        if !selected { self._selectedCells = []; return false }
                        self.deselectAllExcept(i: i, j: j)
                        self._selectedCells = [IndexPath(row: i, section: j)]
                        return selected
                    case .tap:
                        if !selected { self._selectedCells = []; return false }
                        self.deselectAllExcept(i: i, j: j)
                        self._selectedCells = [IndexPath(row: i, section: j)]
                        let cell = self.cell(at: IndexPath(row: i, section: j))
                        mainQueue(delay: 0.3) {
                            cell?.isSelected = false
                        }
                        return selected
                    case .picker:
                        if !selected {
                            if self._selectedCells.contains(IndexPath(row: i, section: j)) {
                                return true
                            }
                            return false
                        }
                        let indexPath = self._selectedCells.first
                        self._selectedCells = [IndexPath(row: i, section: j)]
                        if let indexPath = indexPath { self.cell(at: indexPath)?.isSelected = false }
                        return selected
                    case .sectionPicker:
                        if !selected {
                            if self._selectedCells.contains(IndexPath(row: i, section: j)) {
                                return true
                            }
                            return false
                        }
                        let indexPaths = self._selectedCells.filter { $0.section == j }
                        indexPaths.forEach {
                            self._selectedCells.remove($0)
                        }
                        indexPaths.forEach {
                            self.cell(at: $0)?.isSelected = false
                        }
                        self._selectedCells.insert(IndexPath(row: i, section: j))
                        return selected
                    }
                }
            }
        }
    }
    
    private func cell(at indexPath: IndexPath) -> CellViewModelProtocol? {
        guard sections.count > indexPath.section else { return nil }
        guard sections[indexPath.section].cells.count > indexPath.row else { return nil }
        return sections[indexPath.section].cells[indexPath.row]
    }

    // MARK: - deselection
    private func deselectAllExcept(i targetI: Int, j targetJ: Int) {
        self._selectedCells.forEach({ indexPath in
            if indexPath.row != targetI || indexPath.section != targetJ {
                self.cell(at: indexPath)?.isSelected = false
            }
        })
    }

    public func deselectAllCells() {
        selectedCells.forEach { cell in
            cell.isSelected = false
        }
        self._selectedCells = []
    }
    
    public func isEqual(to viewModel: CollectionViewModelProtocol?) -> Bool {
        self == viewModel
    }
    
    public func copy() -> CollectionViewModelProtocol {
        CollectionViewModel(sections: sections, selectionStyle: selectionStyle)
    }

}

// MARK: - UICollectionViewDelegate
extension CollectionViewModel: UICollectionViewDelegate {

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        contentOffsetChanged.raise(data: scrollView.contentOffset)
    }

}

// MARK: - UITableViewDelegate
extension CollectionViewModel: UITableViewDelegate {

    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let cellViewModel = sections[section].footer
        let view = cellViewModel?.getCell(for: tableView, indexPath: IndexPath(row: -1, section: section), kind: .headerFooter)
        return view
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cellViewModel = sections[section].header
        let view = cellViewModel?.getCell(for: tableView, indexPath: IndexPath(row: -1, section: section), kind: .headerFooter)
        return view
    }

    public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        guard sections.count > section, sections[section].header != nil else { return 0 }
        if let h = sections[section].header?.preferredHeight(for: tableView.safeBounds.height) { return h }
        return 44
    }

    public func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        guard sections.count > section, sections[section].footer != nil else { return 0 }
        if let h = sections[section].footer?.preferredHeight(for: tableView.safeBounds.height) { return h }
        return 44
    }

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.cell(at: indexPath)?.willBeDisplayed(viewModel: self)
    }

    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        sections[section].header?.willBeDisplayed(viewModel: self)
    }

    public func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        sections[section].footer?.willBeDisplayed(viewModel: self)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isScrolling = true
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isScrolling = false
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            isScrolling = false
        }
    }

    public func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: cell(at: indexPath)?.leadingSwipeActions() ?? [])
    }

    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: cell(at: indexPath)?.trailingSwipeActions() ?? [])
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < 0 {
            return UITableView.automaticDimension
        }
        guard indexPath.section < sections.count, indexPath.row < sections[indexPath.section].cells.count else {
            return UITableView.automaticDimension
        }
        if let h = cell(at: indexPath)?.preferredHeight(for: tableView.safeBounds.height) { return h }
        return UITableView.automaticDimension
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section < sections.count else { return UITableView.automaticDimension }
        if let h = sections[section].header?.preferredHeight(for: tableView.safeBounds.height) { return h }
        return UITableView.automaticDimension
    }

    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard section < sections.count else { return UITableView.automaticDimension }
        if let h = sections[section].footer?.preferredHeight(for: tableView.safeBounds.height) { return h }
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if let h = cell(at: indexPath)?.preferredHeight(for: tableView.safeBounds.height) { return h }
        return 44
    }

}

// MARK: - UITableViewDataSource
extension CollectionViewModel: UITableViewDataSource {

    public func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].cells.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellViewModel = cell(at: indexPath)
        return cellViewModel?.getCell(for: tableView, indexPath: indexPath, kind: .cell) as? UITableViewCell ?? UITableViewCell()
    }

}


fileprivate extension Array {
    
    func get(_ index: Int) -> Element? {
        return (index < self.count && index >= 0) ? self[index] : nil
    }
    
}
