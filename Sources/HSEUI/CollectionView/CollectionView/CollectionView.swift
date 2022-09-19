import UIKit

public protocol CollectionViewProtocol: UIView {
    
    var type: CollectionView.CollectionType { get }
    
    var collectionViewModel: CollectionViewModelProtocol? { get }
    var backgroundColor: UIColor? { set get }
    var isEditable: Bool { get }
    var isScrollEnabled: Bool { set get }
    var adjustedContentInset: UIEdgeInsets { get }
    var additionalSafeAreaInsets: UIEdgeInsets { set get }
    var contentSize: CGSize { get }
    
    func reload(with viewModel: CollectionViewModelProtocol?, animated: Bool)
    func scroll(to cell: CellViewModel)
    func setUpRefresher(refreshCallback: Action?)
    func setEditing(_ value: Bool)
    func orientationWillChange(newSize: CGSize)
    func beginRefreshing()
}

public class CollectionView: UIView, CollectionViewProtocol {

    // MARK: - Public Types
    
    public enum CollectionType: Equatable {
        case list
        case grid
        case chips
        case pager
        case web
    }

    // MARK: - Public Properties
    
    public let type: CollectionType
    
    public override var backgroundColor: UIColor? {
        didSet {
            contentView.backgroundColor = backgroundColor
        }
    }

    public var isScrollEnabled: Bool {
        set {
            contentView.isScrollEnabled = newValue
        }
        get {
            contentView.isScrollEnabled
        }
    }
    
    public var contentInset: UIEdgeInsets {
        set {
            contentView.contentInset = newValue
        }
        get {
            contentView.contentInset
        }
    }
    
    public var adjustedContentInset: UIEdgeInsets {
        return contentView.adjustedContentInset
    }
    
    public var spacing: CGFloat {
        set {
            contentView.spacing = newValue
        }
        get {
            contentView.spacing
        }
    }
    
    public var contentSize: CGSize {
        contentView.contentSize
    }

    // collection is editable if it has cells with delete action
    public var isEditable: Bool {
        for section in currentSections {
            for cell in section.cells where cell.isEditable {
                return true
            }
        }
        
        return false
    }
    
    public override var bounds: CGRect {
        didSet {
            guard oldValue != bounds else { return }
            
            if oldValue.width != bounds.width {
                self.throwWidth(bounds.width)
            }
            
            didChangeBounds()
        }
    }
    
    public var additionalSafeAreaInsets: UIEdgeInsets = .zero
    public override var safeBounds: CGRect {
        let safeAreaLeftInset = safeAreaInsets.left + additionalSafeAreaInsets.left
        let safeAreaRightInset = safeAreaInsets.right + additionalSafeAreaInsets.right
        let safeAreaTopInset = safeAreaInsets.top + additionalSafeAreaInsets.top
        let safeAreaBottomInset = safeAreaInsets.bottom + additionalSafeAreaInsets.bottom
        
        return CGRect(x: safeAreaInsets.left + bounds.origin.x,
                      y: safeAreaInsets.top + bounds.origin.y,
                      width: bounds.width - safeAreaLeftInset - safeAreaRightInset,
                      height: bounds.height - safeAreaTopInset - safeAreaBottomInset)
    }
    
    public private(set) var collectionViewModel: CollectionViewModelProtocol? {
        didSet {
            currentSections = collectionViewModel?.sections.map { $0.copy() } ?? []
        }
    }
    
    // MARK: - Private Properties
    
    private let contentView: BaseCollectionViewProtocol
    private var currentSections: [SectionViewModel] = []

    private var refresher: RefreshControl?
    private var keyboardListeners: [EventListener] = []

    // MARK: - Init
    
    public init(type: CollectionType,
                layoutConfigurator: ((UICollectionViewFlowLayout) -> (UICollectionViewFlowLayout))? = nil) {
        self.type = type
        
        switch type {
        case .grid:
            contentView = BaseCollectionView(layoutConfigurator: layoutConfigurator)
            
        case .list:
            contentView = BaseTableView()
            assert(layoutConfigurator == nil)
            
        case .chips:
            contentView = ChipsCollectionView()
            assert(layoutConfigurator == nil)
            
        case .pager:
            contentView = PagerCollectionView()
            assert(layoutConfigurator == nil)
            
        case .web:
            contentView = WebCollectionView()
            assert(layoutConfigurator == nil)
        }
        super.init(frame: .zero)
        
        addSubview(contentView)
        contentView.stickToSuperviewEdges([.top, .bottom])
        contentView.stickToSuperviewSafeEdges([.left, .right])
        contentView.collectionDataSource = CollectionDataSource(self)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGestureRecognizer.cancelsTouchesInView = false
        contentView.addGestureRecognizer(tapGestureRecognizer)
        
        _ = KeyboardObserver.main
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods
    
    public func reload(with viewModel: CollectionViewModelProtocol? = nil, animated: Bool = false) {
        let newViewModel = viewModel ?? collectionViewModel
        
        let reloadBlock = { [weak self] in
            guard let self = self, let newViewModel = newViewModel else { return }
            self.contentView.bind(to: newViewModel)
            
            if animated && self.collectionViewModel != nil && newViewModel is CollectionViewModel {
                self.animateDiff(viewModel: newViewModel)
                self.collectionViewModel = newViewModel
            }
            else {
                self.collectionViewModel = newViewModel
                self.contentView.reloadData()
            }
        }
        
        if collectionViewModel?.isScrolling == true {
            self.refresher?.endRefreshing()
            collectionViewModel?.whenStoppedCallback = { reloadBlock() }
        }
        else if self.refresher?.isRefreshing == true {
            self.refresher?.endRefreshing()
            mainQueue(delay: 0.2) { reloadBlock() }
        }
        else {
            self.refresher?.endRefreshing()
            reloadBlock()
        }
    }
    
    public func reloadSections(_ sections: [SectionViewModel]) {
        guard let viewModel = collectionViewModel else { return }
        var indexesToReload: [Int] = []
        
        for (i, section) in viewModel.sections.enumerated() {
            for sectionToReload in sections where section.id == sectionToReload.id {
                indexesToReload.append(i)
            }
        }
        
        contentView.reloadSections(indexesToReload, with: .fade)
    }
    
    public func reloadCells(_ cells: [CellViewModel]) {
        guard let viewModel = collectionViewModel else { return }
        var indexesToReload: [IndexPath] = []
        
        for (i, section) in viewModel.sections.enumerated() {
            for (j, cell) in section.cells.enumerated() {
                for cellToReload in cells where cell.id == cellToReload.id {
                    indexesToReload.append(IndexPath(item: j, section: i))
                }
            }
        }
        
        contentView.reloadItems(at: indexesToReload, with: .fade)
    }

    public func scroll(to cell: CellViewModel) {
        guard let indexPath = indexPath(for: cell) else {
            assertionFailure("There is no such cell")
            return
        }

        contentView.scroll(to: indexPath)
    }
    
    public func scrollToTop() {
        contentView.scrollToTop()
    }

    public func setEditing(_ value: Bool) {
        contentView.setEditing(value, animated: true)
    }

    public func deselectAllCells() {
        collectionViewModel?.deselectAllCells()
    }
    
    public func setUpRefresher(refreshCallback: Action? = nil) {
        #if !targetEnvironment(macCatalyst)
        guard let refreshCallback = refreshCallback else { return }
        
        if let refresher = refresher {
            refresher.refreshCallback = refreshCallback
        }
        else {
            let refresher = RefreshControl()
            refresher.refreshCallback = refreshCallback
            contentView.addSubview(refresher)
            self.refresher = refresher
        }
        #endif
    }

    public func beginRefreshing() {
        contentView.beginRefreshing()
    }

    public func handleFirstResponder(for cell: CellViewModel) {
        keyboardListeners = []
        keyboardListeners.append(KeyboardEvent.keyboardDidShow.listen { [weak self] (height: CGFloat) in
            guard let self = self else { return }
            self.contentView.contentInset.bottom = height
            guard let indexPath = self.indexPath(for: cell) else { return }
            self.collectionViewModel?.setCellVisible.raise(data: indexPath)
        })
        
        keyboardListeners.append(KeyboardEvent.keyboardWillHide.listen { [weak self] in
            UIView.animate(withDuration: 0.3) {
                self?.contentView.contentInset.bottom = 0
            }
            self?.keyboardListeners = []
        })
    }
    
    open func orientationWillChange(newSize: CGSize) {
        contentView.orientationWillChange(newSize: newSize)
    }
    
    // MARK: - Private Methods
    
    private func didChangeBounds() {
        for section in currentSections {
            section.cells.forEach { $0.configure(for: self) }
            section.footer?.configure(for: self)
            section.header?.configure(for: self)
        }
    }
    
    private func animateDiff(viewModel: CollectionViewModelProtocol) {
        while viewModel.sections.count > currentSections.count {
            currentSections.append(SectionViewModel(cells: viewModel.sections[currentSections.count].cells))
            contentView.insertSections(IndexSet([currentSections.count - 1]), with: .fade)
        }
        
        while viewModel.sections.count < currentSections.count {
            currentSections.removeLast()
            contentView.deleteSections(IndexSet([currentSections.count]), with: .fade)
        }
        
        let animationBlock = {
            var sectionDiffs: [[CollectionDifference<CellViewModel>.Element]] = []
            for i in 0 ..< viewModel.sections.count {
                let diffs = viewModel.sections[i].cells.difference(from: self.currentSections[i].cells, by: {
                    self.compareViewModels(lhs: $0, rhs: $1)
                }).map { $0 }
                sectionDiffs.append(diffs)
            }
            
            for i in 0 ..< sectionDiffs.count {
                let diffs = sectionDiffs[i]
                for j in 0 ..< diffs.count {
                    let diff = diffs[j]
                    switch diff {
                    case .insert(var offset, let cell, _):
                        while true {
                            guard offset < self.currentSections[i].cells.count else { break }
                            guard self.compareViewModels(lhs: self.currentSections[i].cells[offset], rhs: cell) else { break }
                            offset += 1
                        }
                        self.currentSections[i].cells.insert(cell, at: offset)
                        let animation = cell.preferredAnimation ?? .fade
                        self.contentView.insertItems(at: [IndexPath(row: offset, section: i)], with: animation)
                        
                    case .remove(let offset, _, _):
                        let animation = self.currentSections[i].cells[offset].preferredAnimation ?? .fade
                        self.currentSections[i].cells.remove(at: offset)
                        self.contentView.deleteItems(at: [IndexPath(row: offset, section: i)], with: animation)
                    }
                }
            }
        }

        if let table = contentView as? UITableView {
            table.performBatchUpdates {
                animationBlock()
            } // do not join
            table.performBatchUpdates {
                table.indexPathsForVisibleRows?.forEach { ip in
                    if let cell = table.cellForRow(at: ip) as? BaseCellProtocol {
                        let vm = viewModel.sections[ip.section].cells[ip.row]
                        vm.update(cell: cell, collectionView: self)
                    }
                }
                Set(table.indexPathsForVisibleRows?.map { $0.section } ?? []).forEach { section in
                    if let header = table.headerView(forSection: section) as? BaseCellProtocol {
                        let vm = viewModel.sections[section].header
                        vm?.update(cell: header, collectionView: self)
                    }
                    
                    if let footer = table.footerView(forSection: section) as? BaseCellProtocol {
                        let vm = viewModel.sections[section].footer
                        vm?.update(cell: footer, collectionView: self)
                    }
                }
            }
        }
        else if let collection = contentView as? UICollectionView {
            collection.performBatchUpdates {
                animationBlock()
            } // do not join
            collection.performBatchUpdates {
                collection.indexPathsForVisibleItems.forEach { ip in
                    if let cell = collection.cellForItem(at: ip) {
                        let vm = viewModel.sections[ip.section].cells[ip.row]
                        vm.update(cell: cell as! BaseCellProtocol, collectionView: self)
                    }
                }
            }
        }
        else {
            contentView.reloadData()
        }
    }
    
    private func indexPath(for cell: CellViewModel) -> IndexPath? {
        guard let vm = collectionViewModel else { return nil }
        
        for i in 0 ..< vm.sections.count {
            for j in 0 ..< vm.sections[i].cells.count
            where vm.sections[i].cells[j].id == cell.id {
                return IndexPath(row: j, section: i)
            }
        }
        
        return nil
    }
    
    @objc private func dismissKeyboard() {
        contentView.endEditing(false)
    }

}

// MARK: - Protocol UITableViewDataSource

extension CollectionView: UITableViewDataSource {

    public func numberOfSections(in tableView: UITableView) -> Int {
        return currentSections.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentSections[section].cells.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellViewModel = currentSections[indexPath.section].cells[indexPath.row]
        return cellViewModel.getCell(for: tableView, indexPath: indexPath, kind: .cell) as! UITableViewCell
    }

    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        currentSections[indexPath.section].cells[indexPath.row].isEditable
    }

}

// MARK: - Protocol UICollectionViewDataSource

extension CollectionView: UICollectionViewDataSource {

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return currentSections.count
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentSections[section].cells.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellViewModel = currentSections[indexPath.section].cells[indexPath.row]
        return cellViewModel.getCell(for: collectionView, indexPath: indexPath)
    }

}

// MARK: - Protocol CustomCollectionViewDataSource

extension CollectionView: CustomCollectionViewDataSource {
    
    func cells() -> [CellViewModel] {
        return currentSections.first?.cells ?? []
    }
    
}

// MARK: - Protocol WebViewDataSource

extension CollectionView: WebViewDataSource {
    
    func link() -> String? {
        return (collectionViewModel as? WebViewModel)?.link
    }
    
}

// MARK: - Protocol PagerPresentable

extension CollectionView: PagerPresentable {
    
    public var currentIndex: Int {
        (contentView as? PagerPresentable)?.currentIndex ?? 0
    }
    
    public var pagerDelegate: PagerDelegate? {
        set {
            (contentView as? PagerPresentable)?.pagerDelegate = newValue
        }
        get {
            (contentView as? PagerPresentable)?.pagerDelegate
        }
    }
    
    public func changePage(newIndex: Int, animated: Bool) {
        (contentView as? PagerPresentable)?.changePage(newIndex: newIndex, animated: animated)
    }
    
}

extension CollectionView {
    
    func compareViewModels(lhs: CellViewModel, rhs: CellViewModel) -> Bool {
        if lhs.id == rhs.id { return true }
        if String(describing: lhs) != String(describing: rhs) { return false }
        if let tag = lhs.getCellView()?.tag, tag != 0 { return false }
        if let tag = rhs.getCellView()?.tag, tag != 0 { return false }
        
        if let view = lhs.getCellView() {
            if rhs.updateView(view: view) == false { return false }
        }
        else if let view = rhs.getCellView() {
            if lhs.updateView(view: view) == false { return false }
        }
        
        return true
    }
    
}

private class KeyboardObserver: NSObject {
    
    static let main = KeyboardObserver()
    
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    deinit {
         NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleKeyboard(notification: NSNotification) {
        switch notification.name {
        case UIResponder.keyboardWillShowNotification:
            KeyboardEvent.keyboardWillShow.raise()
            
        case UIResponder.keyboardDidShowNotification:
            if let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect {
                KeyboardEvent.keyboardDidShow.raise(data: keyboardSize.height)
            }
            
        case UIResponder.keyboardWillHideNotification:
            KeyboardEvent.keyboardWillHide.raise()
            
        case UIResponder.keyboardDidHideNotification:
            KeyboardEvent.keyboardDidHide.raise()
            
        default:
            break
        }
    }
    
}
