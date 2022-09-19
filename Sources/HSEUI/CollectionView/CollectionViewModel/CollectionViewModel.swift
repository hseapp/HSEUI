import UIKit

open class CollectionViewModel: NSObject, CollectionViewModelProtocol {

    // MARK: - Internal Properties

    public var contentOffsetChanged = Event.new()
    public var setCellVisible = Event.new()
    
    public var whenStoppedCallback: Action?
    
    public var sections: [SectionViewModel] {
        didSet { updateSelectionBlocks() }
    }
    
    public var selectedCells: [CellViewModel] {
        return selectedCellsIndexPaths.compactMap { self.cell(at: $0) }
    }
    
    public var isScrolling: Bool = false {
        didSet {
            guard isScrolling == false, isScrolling != oldValue else { return }
            whenStoppedCallback?()
        }
    }
    
    // MARK: - Private Properties
    
    private var selectionStyle: SelectionStyle = .none
    private var selectedCellsIndexPaths: Set<IndexPath> = []

    // MARK: - Init
    
    public init(sections: [SectionViewModel] = [], selectionStyle: SelectionStyle = .none) {
        self.sections = sections
        self.selectionStyle = selectionStyle
        super.init()
        self.updateSelectionBlocks()
    }

    public init(section: SectionViewModel, selectionStyle: SelectionStyle = .none) {
        self.sections = [section]
        self.selectionStyle = selectionStyle
        super.init()
        self.updateSelectionBlocks()
    }

    public init(cells: [CellViewModel], selectionStyle: SelectionStyle = .none) {
        self.sections = [SectionViewModel(cells: cells)]
        self.selectionStyle = selectionStyle
        super.init()
        self.updateSelectionBlocks()
    }

    public init(cell: CellViewModel) {
        self.sections = [SectionViewModel(cells: [cell])]
        self.selectionStyle = .none
        super.init()
        self.updateSelectionBlocks()
    }

    // MARK: - Public Methods
    
    public func deselectAllCells() {
        selectedCells.forEach { cell in
            cell.isSelected = false
        }
        self.selectedCellsIndexPaths = []
    }
    
    public func copy() -> CollectionViewModelProtocol {
        CollectionViewModel(sections: sections, selectionStyle: selectionStyle)
    }
    
    // MARK: - Private Methods
    
    private func updateSelectionBlocks() {
        sections.enumerated().forEach { j, section in
            section.cells.enumerated().forEach { i, cell in
                cell.selectionBlock = { [weak self] selected in
                    guard let self = self else { return false }
                    let currentIndexPath = IndexPath(row: i, section: j)
                    
                    switch self.selectionStyle {
                    case .none:
                        return false
                        
                    case .multiple:
                        if selected {
                            self.selectedCellsIndexPaths.insert(currentIndexPath)
                        }
                        else {
                            self.selectedCellsIndexPaths.remove(currentIndexPath)
                        }
                        return selected
                        
                    case .single:
                        guard selected else {
                            self.selectedCellsIndexPaths.remove(currentIndexPath)
                            return false
                        }
                        
                        self.deselectAllExcept(i: i, j: j)
                        self.selectedCellsIndexPaths = [currentIndexPath]
                        return selected
                        
                    case .tap:
                        guard selected else {
                            self.selectedCellsIndexPaths.remove(currentIndexPath)
                            return false
                        }
                        
                        self.deselectAllExcept(i: i, j: j)
                        self.selectedCellsIndexPaths = [currentIndexPath]
                        
                        let cell = self.cell(at: currentIndexPath)
                        mainQueue(delay: 0.3) { cell?.isSelected = false }
                        return selected
                        
                    case .picker:
                        guard selected else {
                            if self.selectedCellsIndexPaths.contains(currentIndexPath) { return true }
                            return false
                        }
                        
                        let indexPath = self.selectedCellsIndexPaths.first
                        self.selectedCellsIndexPaths = [currentIndexPath]
                        if let indexPath = indexPath { self.cell(at: indexPath)?.isSelected = false }
                        return selected
                        
                    case .sectionPicker:
                        guard selected else {
                            if self.selectedCellsIndexPaths.contains(currentIndexPath) { return true }
                            return false
                        }
                        
                        let indexPaths = self.selectedCellsIndexPaths.filter { $0.section == j }
                        indexPaths.forEach { self.selectedCellsIndexPaths.remove($0) }
                        indexPaths.forEach { self.cell(at: $0)?.isSelected = false }
                        
                        self.selectedCellsIndexPaths.insert(currentIndexPath)
                        return selected
                    }
                }
            }
        }
    }
    
    private func cell(at indexPath: IndexPath) -> CellViewModel? {
        guard sections.count > indexPath.section else { return nil }
        guard sections[indexPath.section].cells.count > indexPath.row else { return nil }
        return sections[indexPath.section].cells[indexPath.row]
    }

    private func deselectAllExcept(i targetI: Int, j targetJ: Int) {
        self.selectedCellsIndexPaths.forEach { indexPath in
            if indexPath.row != targetI || indexPath.section != targetJ {
                self.cell(at: indexPath)?.isSelected = false
            }
        }
    }

}

// MARK: - Protocol UICollectionViewDelegate

extension CollectionViewModel: UICollectionViewDelegate {

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        contentOffsetChanged.raise(data: scrollView.contentOffset)
    }

}

// MARK: - Protocol UITableViewDelegate

extension CollectionViewModel: UITableViewDelegate {
    
    // MARK: Cells
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < 0 {
            return UITableView.automaticDimension
        }
        
        guard indexPath.section < sections.count, indexPath.row < sections[indexPath.section].cells.count else {
            return UITableView.automaticDimension
        }
        
        if let height = cell(at: indexPath)?.preferredHeight(for: tableView.safeBounds.height) { return height }
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = cell(at: indexPath)?.preferredHeight(for: tableView.safeBounds.height) { return height }
        return 44
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.cell(at: indexPath)?.willBeDisplayed(viewModel: self)
    }
    
    // MARK: Headers

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cellViewModel = sections[section].header
        let view = cellViewModel?.getCell(for: tableView, indexPath: IndexPath(row: -1, section: section), kind: .headerFooter)
        return view
    }

    public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        guard sections.count > section, sections[section].header != nil else { return 0 }
        if let height = sections[section].header?.preferredHeight(for: tableView.safeBounds.height) { return height }
        return 44
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section < sections.count else { return UITableView.automaticDimension }
        if let height = sections[section].header?.preferredHeight(for: tableView.safeBounds.height) { return height }
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        sections[section].header?.willBeDisplayed(viewModel: self)
    }
    
    // MARK: Footers
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let cellViewModel = sections[section].footer
        let view = cellViewModel?.getCell(for: tableView, indexPath: IndexPath(row: -1, section: section), kind: .headerFooter)
        return view
    }

    public func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        guard sections.count > section, sections[section].footer != nil else { return 0 }
        if let height = sections[section].footer?.preferredHeight(for: tableView.safeBounds.height) { return height }
        return 44
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard section < sections.count else { return UITableView.automaticDimension }
        if let height = sections[section].footer?.preferredHeight(for: tableView.safeBounds.height) { return height }
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        sections[section].footer?.willBeDisplayed(viewModel: self)
    }
    
    // MARK: Scroll View
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isScrolling = true
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isScrolling = false
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else { return }
        isScrolling = false
    }
    
    // MARK: Swipe Actions

    public func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: cell(at: indexPath)?.leadingSwipeActions() ?? [])
    }

    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: cell(at: indexPath)?.trailingSwipeActions() ?? [])
    }

}

// MARK: - Private Helpers

private extension Array {
    
    func get(_ index: Int) -> Element? {
        return (index < self.count && index >= 0) ? self[index] : nil
    }
    
}
