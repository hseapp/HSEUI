import UIKit
import HSEUI

open class CollectionViewController: UIViewController {

    // MARK: - CollectionViewControllerFeatures
    
    public struct CollectionViewControllerFeatures: OptionSet {
        
        public let rawValue: Int16
        
        public static var header = CollectionViewControllerFeatures(rawValue: 1)
        public static var pageSelector = CollectionViewControllerFeatures(rawValue: 1 << 1)
        public static var refresh = CollectionViewControllerFeatures(rawValue: 1 << 2)
        public static var edit = CollectionViewControllerFeatures(rawValue: 1 << 3)
        public static var bottomButton = CollectionViewControllerFeatures(rawValue: 1 << 4)
        public static var search = CollectionViewControllerFeatures(rawValue: 1 << 5)
        public static var skeleton = CollectionViewControllerFeatures(rawValue: 1 << 6)
        public static var topView = CollectionViewControllerFeatures(rawValue: 1 << 7)
        public static var cache = CollectionViewControllerFeatures(rawValue: 1 << 8)
        public static var dataFetch = CollectionViewControllerFeatures(rawValue: 1 << 9)
        // Make sure you do not add CollectionViewControllerFeatures(rawValue: 1 << 16)
        // Else change Int16 to Int32 and rewrite this comment
        
        public init(rawValue: Int16) {
            self.rawValue = rawValue
        }
    }
    
    // MARK: - constants
    
    enum Layout {
        static let bottomButtonHeight: CGFloat = 68
    }

    // MARK: - ui
    
    public var bottomButton: BottomButtonView
    
    public var topView: UIView = UIView()

    public var collectionView: CollectionViewProtocol

    // MARK: - features
    
    public var withPageSelector: Bool

    public private(set) var withHeader: Bool

    public private(set) var withRefresh: Bool
    
    public private(set) var useSkeleton: Bool
    
    public private(set) var withTopView: Bool

    public private(set) var withBottomButton: Bool

    public private(set) var withEditButton: Bool

    public private(set) var withSearch: Bool
    
    public private(set) var withCache: Bool
    
    public private(set) var withDataFetch: Bool

    public var selectorTitles: [String]
    
    public var defaultPageIndex: Int
    
    public let loader = HSELoader()

    // MARK: - search
    
    @objc public private(set) var searchController: UISearchController?

    public var query: String = ""

    // MARK: - other properties
    
    private var refreshCallback: Action? {
        withRefresh ? fetchData : nil
    }
    
    private var didUseKeyboard: Bool = false
    
    public var listeners: [EventListener] = []

    // MARK: - init
    
    public init(
        type: CollectionView.CollectionType = .list,
        layoutConfigurator: ((UICollectionViewFlowLayout) -> (UICollectionViewFlowLayout))? = nil,
        tableColor: UIColor = Color.Base.mainBackground,
        features: CollectionViewControllerFeatures = [],
        selectorTitles: [String] = [],
        defaultPageIndex: Int = 0
    ) {
        bottomButton = BottomButtonView()
        self.withBottomButton = features.contains(.bottomButton)
        self.withEditButton = features.contains(.edit)
        self.withRefresh = features.contains(.refresh)
        self.useSkeleton = features.contains(.skeleton)
        
        self.withPageSelector = features.contains(.pageSelector)
        self.withSearch = features.contains(.search)
        self.selectorTitles = selectorTitles
        self.defaultPageIndex = defaultPageIndex
        self.withHeader = features.contains(.header)
        self.withTopView = features.contains(.topView)
        self.withCache = features.contains(.cache)
        self.withDataFetch = features.contains(.dataFetch)
        
        let listsCollectionFeatures: [CollectionViewControllerFeatures] = [.header, .pageSelector]
        if listsCollectionFeatures.allSatisfy({ !features.contains($0) }) && type != .pager {
            collectionView = CollectionView(type: type, layoutConfigurator: layoutConfigurator)
        } else {
            collectionView = ListsCollectionView()
        }

        super.init(nibName: nil, bundle: nil)

        collectionView.backgroundColor = tableColor
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - view life cycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBar()
        if withBottomButton {
            setUpBottomButtonView()
        }
        if withTopView {
            setUpTopView()
        }
        commonInit()
    }

    open override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        // this is a workaround to present smooth animation when search controller becomes active
        if didUseKeyboard {
            UIView.animate(withDuration: 0.4) {
                self.view.layoutIfNeeded()
                self.navigationController?.view.layoutIfNeeded()
            }
        }
    }

    // MARK: - should be overridden
    
    open func fetchData() {
        fatalError("Should be overridden if collection has refresh")
    }

    open func setUpBottomButtonView() {
        fatalError("Should be overridden")
    }

    open func buildHeaderModel() -> CollectionViewModel? {
        if withHeader {
            fatalError("Should be overridden if pager has header")
        } else {
            return nil
        }
    }

    /// build all `CollectionViewModels` and create array from them
    open func collectModels() -> [CollectionViewModelProtocol] {
        if let sections = collectSections() {
            return [CollectionViewModel(sections: sections)]
        }
        return []
    }
    
    /// build all `SectionViewModel` and create array from them
    open func collectSections() -> [SectionViewModel]? { return nil }
    
    open func collectionViewModel() -> CollectionViewModelProtocol {
        let models = collectModels()
        
        if collectionView is ListsCollectionView {
            return PagerViewModel(pages: models.enumerated().map { PageViewModel(title: ($0 < selectorTitles.count && withPageSelector) ? selectorTitles[$0] : nil, viewModel: $1)}, header: buildHeaderModel())
        }
        
        return models.first ?? CollectionViewModel()
    }

    // MARK: - set up
    
    open func commonInit() {
        view.backgroundColor = Color.Base.mainBackground
        
        if withRefresh {
            collectionView.setUpRefresher(refreshCallback: refreshCallback)
        }

        view.addSubview(collectionView)
        collectionView.stickToSuperviewSafeEdges([.left, .right])
        if collectionView.type == .chips {
            collectionView.stickToSuperviewSafeEdges([.top, .bottom])
        } else {
            collectionView.stickToSuperviewEdges([.top, .bottom])
        }
        
        if withTopView {
            let cover = UIVisualEffectView(effect: UIBlurEffect(style: .defaultHSEUI))
            
            cover.contentView.addSubview(topView)
            topView.stickToSuperviewEdges(.all)
            
            if let navController = navigationController {
                (navController as? CustomNavigationController)?.addTopView(cover, for: self)
            } else {
                view.addSubview(cover)
                cover.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
                cover.stickToSuperviewEdges([.left, .right])
            }
        }

        if withBottomButton {
            view.addSubview(bottomButton)
            bottomButton.stickToSuperviewSafeEdges([.left, .right])
            bottomButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        }
        
        if withRefresh || withDataFetch {
            if withCache {
                updateCollection(animated: false)
                mainQueue(delay: 0.2) {
                    self.collectionView.beginRefreshing()
                    self.fetchData()
                }
            } else {
                if useSkeleton {
                    showSkeletonOrLoader()
                } else {
                    showOverflow(loader)
                }
                fetchData()
            }
        } else {
            updateCollection(animated: false)
        }
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        additionalSafeAreaInsets.top = withTopView ? topView.bounds.height : 0
        additionalSafeAreaInsets.bottom = withBottomButton ? Layout.bottomButtonHeight : 0
    }
    
    open func setUpTopView() {
        if withTopView {
            fatalError("Should be overridden")
        }
    }

    open func setUpNavBar() {
        if withEditButton {
            editButtonItem.tintColor = Color.Base.brandTint
            navigationItem.rightBarButtonItem = editButtonItem
            editButtonItem.isEnabled = false
        }

        if withSearch {
            searchController = UISearchController(searchResultsController: nil)
            searchController?.obscuresBackgroundDuringPresentation = false
            searchController?.searchResultsUpdater = self
            searchController?.searchBar.delegate = self
            searchController?.searchBar.tintColor = Color.Base.brandTint
            searchController?.searchBar.searchTextField.tokenBackgroundColor = Color.Base.brandTint
            searchController?.searchBar.returnKeyType = .search
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        }
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.orientationWillChange(newSize: size)
    }
    
    // MARK: - collection update logic
    
    public func updateCollection(animated: Bool = true) {
        let viewModel = collectionViewModel()
        collectionView.reload(with: viewModel, animated: animated)
        
        removeOverflow()
        editButtonItem.isEnabled = true
    }

    // MARK: - handlers
    
    open override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        collectionView.setEditing(editing)
    }

    // MARK: - helpers
    
    public func toggleEditButton() {
        let isEditable = collectionView.isEditable
        editButtonItem.isEnabled = isEditable
        if !isEditable && isEditing {
            setEditing(false, animated: true)
        }
    }
    
}

// MARK: - protocols UISearchResultsUpdating, UISearchBarDelegate

extension CollectionViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    open func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }

        if query == searchText { return }
        query = searchText

        updateCollection()
    }
    
    open func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.query = ""
        
        updateCollection()
    }
    
    open func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        didUseKeyboard = true
    }
    
    open func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        didUseKeyboard = true
    }
    
}
