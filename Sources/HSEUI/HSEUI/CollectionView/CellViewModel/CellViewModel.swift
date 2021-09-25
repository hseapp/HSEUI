import UIKit

open class CellViewModel: CellViewModelProtocol {
    
    // MARK: - CellPresentable properties
    public lazy var voiceOver = UIAccessibilityElement(accessibilityContainer: self) {
        didSet {
            setVoiceOver(for: view?.voiceOverView())
        }
    }
    
    public let id = Nonce()
    
    public var selectionBlock: ((Bool) -> Bool)?
    
    public var isEditable: Bool {
        deleteAction != nil
    }

    public var isSelected: Bool {
        get {
            _isSelected
        }
        set {
            _isSelected = newValue
            view?.setSelected(newValue)
        }
    }
    
    public var preferredAnimation: UITableView.RowAnimation?
    
    // MARK: - open properties
    open var selectionCallback: ((Bool) -> Void)?
        
    // MARK: - cell creation
    private let viewType: UIView.Type
    
    private var registerIfNeeded: ((UIView, UITableView.ElementKind) -> ())?
    
    private var getCollectionCell: ((UICollectionView, IndexPath) -> UICollectionViewCell)?
    
    private var getTableCell: ((UITableView, IndexPath, UITableView.ElementKind) -> UIView)?
    
    private var applyConfigurator: Action?
    
    private var viewCheckAndUpdate: (UIView?) -> Bool = { _ in false }

    // MARK: - private properties
    private var _isSelected: Bool = false {
        didSet {
            if oldValue != _isSelected {
                selectionCallback?(_isSelected)
            }
        }
    }

    // MARK: - public properties
    public var deleteAction: Action?
    
    public weak var view: BaseCellProtocol? {
        didSet {
            oldValue?.currentViewModel = nil
            view?.setViewModel(self)
            view?.setSelectionBlock(createSelectionBlock())
            UIView.performWithoutAnimation {
                view?.setSelected(isSelected)
            }
        }
    }
    
    /// This property is used to store link on `CustomCollectionCell`
    private var customCollectionCell: CustomCollectionCell<UIView>?
    
    // MARK: - initializers
    public init<T: UIView>(configurator: CellViewConfigurator<T>) {
        viewType = T.self
        setUpReuse(with: configurator)
    }

    public init<T: UIView>(
        view: T.Type,
        configureView: ((T) -> Void)? = nil,
        tapCallback: Action? = nil,
        useChevron: Bool? = nil
    ) {
        viewType = T.self
        let configurator = CellViewConfigurator<T>.builder()
            .setUseChevron(useChevron ?? (tapCallback != nil))
            .setConfigureView(configureView)
            .setTapCallback(tapCallback == nil ? nil : { [weak self] in
                self?.markDirty()
                tapCallback?()
            })
            .setSelected(self._isSelected)
            .build()
        setUpReuse(with: configurator)
    }
    
    // MARK: - CellPresentable methods
    public func initView() -> UIView {
        let view = viewType.init()
        customCollectionCell = CustomCollectionCell(view: view)
        self.view = customCollectionCell
        applyConfigurator?()
        return view
    }
    
    public func updateView(view: UIView?) -> Bool {
        return viewCheckAndUpdate(view)
    }
    
    public func update(cell: BaseCellProtocol, collectionView: CollectionView) {
        view = cell
        applyConfigurator?()
        configure(for: collectionView)
    }
    
    public func getCell(for collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        registerIfNeeded?(collectionView, .cell)
        let cell = getCollectionCell?(collectionView, indexPath) ?? UICollectionViewCell()
        view = cell as? BaseCellProtocol
        applyConfigurator?()
        configure(for: collectionView.superview as! CollectionView)
        return cell
    }

    public func getCell(for tableView: UITableView, indexPath: IndexPath, kind: UITableView.ElementKind = .cell) -> UIView {
        registerIfNeeded?(tableView, kind)
        let cell = getTableCell?(tableView, indexPath, kind) ?? UITableViewCell()
        view = cell as? BaseCellProtocol
        applyConfigurator?()
        configure(for: tableView.superview as! CollectionView)
        return cell
    }
    
    open func willBeDisplayed(viewModel: CollectionViewModel) { }
    
    open func leadingSwipeActions() -> [UIContextualAction] { return [] }

    open func trailingSwipeActions() -> [UIContextualAction] {
        if let deleteAction = deleteAction {
            return [UIContextualAction(style: .destructive, title: NSLocalizedString("common.delete", comment: ""), handler: { (_, _, completion) in
                self.preferredAnimation = .left
                self.markDirty()
                completion(true)
                deleteAction()
            })]
        } else {
            return []
        }
    }
    
    // MARK: - Handle base cell creation
    private func setUpReuse<T: UIView>(with configurator: CellViewConfigurator<T>) {
        let reuseId = String(describing: viewType.self) + String(describing: Self.self)
        registerIfNeeded = { (view, kind) in
            if let collectionView = view as? UICollectionView {
                collectionView.register(T.self, reuseId: reuseId)
            } else if let tableView = view as? UITableView {
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
            guard view?.classForCoder == T.self else { return false }
            guard let view = view as? T else { return false }
            view.tag = 0
            self?.customCollectionCell = CustomCollectionCell(view: view)
            self?.view = self?.customCollectionCell
            self?.applyConfigurator?()
            return true
        }
        saveConfigurator(configurator)
    }
    
    private func saveConfigurator<T: UIView>(_ configurator: CellViewConfigurator<T>) {
        applyConfigurator = { [weak self] in
            self?.view?.updateConfigurator(with: configurator)
        }
    }
    
    // MARK: - work with view via delegate
    public func apply<T: UIView>(type: T.Type, _ block: (T) -> Void) {
        view?.apply(block)
    }
    
    public func markDirty() {
        getCellView()?.tag = Nonce()
    }
    
    public func getCellView() -> UIView? {
        view?.getCellView()
    }
    
    public func updateConfigurator<T: UIView>(_ configurator: CellViewConfigurator<T>) {
        view?.updateConfigurator(with: configurator)
        saveConfigurator(configurator)
    }

    // MARK: - open methods
    open func configure(for collectionView: CollectionView) {
        if !collectionView.type.fullWidth {
            if let width = preferredWidth(for: collectionView.safeBounds.width) {
                view?.setWidth(floor(width))
            }
        }
        setVoiceOver(for: view?.voiceOverView())
        view?.getCellView().tag = 0
        view?.getCellView().throwWidth(collectionView.safeBounds.width)
        if let height = preferredHeight(for: collectionView.safeBounds.height) {
            view?.setHeight(floor(height))
        }
    }

    open func preferredWidth(for parentWidth: CGFloat) -> CGFloat? {
        return nil
    }

    open func preferredHeight(for parentHeight: CGFloat) -> CGFloat? {
        return nil
    }
    
    // MARK: - private methods
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
    
    private func setVoiceOver(for view: UIView?) {
        view?.accessibilityElementsHidden = voiceOver.accessibilityElementsHidden
        view?.accessibilityLabel = voiceOver.accessibilityLabel
        view?.accessibilityHint = voiceOver.accessibilityHint
        view?.accessibilityTraits = voiceOver.accessibilityTraits
        view?.accessibilityValue = voiceOver.accessibilityValue
    }

}

// MARK: - Equatable
extension CellViewModel: Equatable {

    public static func == (lhs: CellViewModel, rhs: CellViewModel) -> Bool {
        return lhs.id == rhs.id
    }

}

// MARK: - Hashable
extension CellViewModel: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}

extension CellViewModel: CellViewModelItem {
    
    public func reset() {
        view = nil
    }
    
}
