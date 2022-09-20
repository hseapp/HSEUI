import UIKit

public enum CellViewModelFeatures {
    case roundTopCorners
    case roundBottomCorners
}

open class CellViewModel {
    
    // MARK: - Public Properties
    
    public let id = Nonce()
    
    open var selectionCallback: ((Bool) -> Void)?
    public var selectionBlock: ((Bool) -> Bool)?
    
    public var deleteAction: Action?
    public var preferredAnimation: UITableView.RowAnimation?
    
    public var isEditable: Bool {
        deleteAction != nil
    }

    public var isSelected: Bool {
        get {
            _isSelected
        }
        set {
            _isSelected = newValue
            baseCell?.setSelected(newValue)
        }
    }
    
    public var features: Set<CellViewModelFeatures> = [] {
        didSet { applyFeatures() }
    }
    
    // MARK: - Internal Properties
    
    weak var baseCell: BaseCellProtocol? {
        didSet {
            oldValue?.currentCellViewModel = nil
            baseCell?.setViewModel(self)
            baseCell?.setSelectionBlock(createSelectionBlock())
            UIView.performWithoutAnimation {
                baseCell?.setSelected(isSelected)
            }
        }
    }
        
    // MARK: - Private Properties
    
    private let viewType: UIView.Type
    
    private var getTableCell: ((UITableView, IndexPath, UITableView.ElementKind) -> UIView)?
    private var getCollectionCell: ((UICollectionView, IndexPath) -> UICollectionViewCell)?
    private var registerIfNeeded: ((UIView, UITableView.ElementKind) -> ())?
    
    private var viewCheckAndUpdate: (UIView?) -> Bool = { _ in false }
    private var applyConfigurator: Action?
    
    // This property is used to store link on CustomCollectionCell because baseCell is weak
    private var customCollectionCell: CustomCollectionCell<UIView>?

    private var _isSelected: Bool = false {
        didSet {
            if oldValue != _isSelected {
                selectionCallback?(_isSelected)
            }
        }
    }
    
    // MARK: - Init
    
    public init<T: UIView>(configurator: CellViewConfigurator<T>) {
        viewType = T.self
        setUpReuse(with: configurator)
    }

    public init<T: UIView>(view: T.Type,
                           configureView: ((T) -> Void)? = nil,
                           tapCallback: Action? = nil,
                           useChevron: Bool? = nil) {
        viewType = T.self
        let configurator = CellViewConfigurator<T>.builder()
            .setUseChevron(useChevron ?? (tapCallback != nil))
            .setConfigureView(configureView)
            .setTapCallback(tapCallback)
            .setSelected(self._isSelected)
            .build()
        
        setUpReuse(with: configurator)
    }
    
    // MARK: - Open Methods
    
    open func configure(for collectionView: CollectionView) {
        if !collectionView.type.fullWidth, let width = preferredWidth(for: collectionView.safeBounds.width) {
            baseCell?.setWidth(floor(width))
        }
        
        baseCell?.getCellView().tag = 0
        baseCell?.getCellView().throwWidth(collectionView.safeBounds.width)
        
        if let height = preferredHeight(for: collectionView.safeBounds.height) {
            baseCell?.setHeight(floor(height))
        }
    }

    open func preferredWidth(for parentWidth: CGFloat) -> CGFloat? { return nil }

    open func preferredHeight(for parentHeight: CGFloat) -> CGFloat? { return nil }
    
    open func willBeDisplayed(viewModel: CollectionViewModel) { /* Override in subclass */ }
    
    open func leadingSwipeActions() -> [UIContextualAction] { return [] }

    open func trailingSwipeActions() -> [UIContextualAction] {
        guard let deleteAction = deleteAction else {
            return []
        }

        return [UIContextualAction(style: .destructive,
                                   title: NSLocalizedString("common.delete", comment: ""),
                                   handler: { _, _, completion in
            self.preferredAnimation = .left
            self.markDirty()
            completion(true)
            deleteAction()
        })]
    }

    // MARK: - Public Methods
    
    public func initView() -> UIView {
        let view = viewType.init()
        customCollectionCell = CustomCollectionCell(view: view)
        self.baseCell = customCollectionCell
        applyConfigurator?()
        applyFeatures()
        return view
    }
    
    public func updateView(view: UIView?) -> Bool {
        return viewCheckAndUpdate(view)
    }
    
    public func update(cell: BaseCellProtocol, collectionView: CollectionView) {
        baseCell = cell
        applyConfigurator?()
        configure(for: collectionView)
        applyFeatures()
    }
    
    public func getCell(for tableView: UITableView, indexPath: IndexPath, kind: UITableView.ElementKind = .cell) -> UIView {
        registerIfNeeded?(tableView, kind)
        let cell = getTableCell?(tableView, indexPath, kind) ?? UITableViewCell()
        baseCell = cell as? BaseCellProtocol
        applyConfigurator?()
        configure(for: tableView.superview as! CollectionView)
        applyFeatures()
        return cell
    }
    
    public func getCell(for collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        registerIfNeeded?(collectionView, .cell)
        let cell = getCollectionCell?(collectionView, indexPath) ?? UICollectionViewCell()
        baseCell = cell as? BaseCellProtocol
        applyConfigurator?()
        configure(for: collectionView.superview as! CollectionView)
        applyFeatures()
        return cell
    }
    
    public func markDirty() {
        getCellView()?.tag = Nonce()
    }
    
    public func apply<T: UIView>(type: T.Type, _ block: (T) -> Void) {
        baseCell?.apply(block)
    }
    
    public func getCellView() -> UIView? {
        baseCell?.getCellView()
    }
    
    public func updateConfigurator<T: UIView>(_ configurator: CellViewConfigurator<T>) {
        applyConfigurator = { [weak self] in
            self?.baseCell?.updateConfigurator(with: configurator)
        }
        applyConfigurator?()
    }
    
    public func highlight(backgroundColor: UIColor, with highlightColor: UIColor, overallDuration: TimeInterval) {
        apply(type: CellView.self) { view in
            view.highlight(backgroundColor: backgroundColor,
                           with: highlightColor,
                           overallDuration: overallDuration,
                           completion: nil)
        }
    }
    
    // MARK: - Private Methods
    
    private func setUpReuse<T: UIView>(with configurator: CellViewConfigurator<T>) {
        let reuseId = String(describing: viewType.self) + String(describing: Self.self)
        
        registerIfNeeded = { (view, kind) in
            if let collectionView = view as? UICollectionView {
                collectionView.register(T.self, reuseId: reuseId)
            }
            else if let tableView = view as? UITableView {
                tableView.register(T.self, kind: kind, reuseId: reuseId)
            }
        }
        
        getCollectionCell = { (collectionView, indexPath) in
            let cell = collectionView.dequeue(T.self, for: indexPath, reuseId: reuseId)
            return cell
        }
        
        getTableCell = { (tableView, indexPath, kind) in
            let cell = tableView.dequeue(T.self, for: indexPath, kind: kind, reuseId: reuseId)
            return cell
        }
        
        viewCheckAndUpdate = { [weak self] view in
            guard view?.classForCoder == T.self, let view = view as? T else { return false }
            view.tag = 0
            self?.customCollectionCell = CustomCollectionCell(view: view)
            self?.baseCell = self?.customCollectionCell
            self?.applyConfigurator?()
            return true
        }
        
        applyConfigurator = { [weak self] in
            self?.baseCell?.updateConfigurator(with: configurator)
        }
    }
    
    private func applyFeatures() {
        guard !(baseCell is CustomCollectionCell<UIView>) else { return }
        guard let baseCellView = baseCell?.baseCellView else { return }
        
        guard
            features.contains(.roundTopCorners) || features.contains(.roundBottomCorners)
        else {
            baseCellView.clipsToBounds = false
            baseCellView.layer.cornerRadius = 0
            baseCellView.layer.maskedCorners = []
            return
        }
        
        var cornerMask = CACornerMask()
        if features.contains(.roundTopCorners) {
            cornerMask.insert(.layerMaxXMinYCorner)
            cornerMask.insert(.layerMinXMinYCorner)
        }
        
        if features.contains(.roundBottomCorners) {
            cornerMask.insert(.layerMaxXMaxYCorner)
            cornerMask.insert(.layerMinXMaxYCorner)
        }
        
        baseCellView.clipsToBounds = true
        baseCellView.layer.cornerRadius = 12
        baseCellView.layer.maskedCorners = cornerMask
    }
    
    private func createSelectionBlock() -> (Bool) -> Bool  {
        return { [weak self] selected in
            guard let self = self else { return false }
            if let newSelected = self.selectionBlock?(selected) {
                self._isSelected = newSelected
                return newSelected
            }
            
            return self._isSelected
        }
    }

}

// MARK: - Protocol Hashable

extension CellViewModel: Hashable {
    
    public static func == (lhs: CellViewModel, rhs: CellViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}

// MARK: - CollectionType Extension

private extension CollectionView.CollectionType {
    
    var fullWidth: Bool {
        switch self {
        case .list, .pager, .web:
            return true
            
        case .grid, .chips:
            return false
        }
    }
    
}
