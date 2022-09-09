import UIKit

// MARK: - namespace
enum ListsCollection { }

// MARK: - CollectionWithHeader main class
public class ListsCollectionView: UIView, CollectionViewProtocol {
    
    // MARK: - States
    private enum ReloadState {
        case `default`
        case needReload(CollectionViewModelProtocol?, Bool)
    }
    
    private enum RefresherState {
        case `default`
        case needStopRefresher
        case stoppingRefresh
    }
    
    private var reloadState: ReloadState = .default
    private var refresherState: RefresherState = .default
    
    // MARK: - CollectionViewProtocol
    public var type: CollectionView.CollectionType { return .pager }
    
    public private(set) var collectionViewModel: CollectionViewModelProtocol?
    
    public var isEditable: Bool {
        pages[currentIndex]?.findChildren(CollectionView.self).first?.isEditable ?? false
    }
    
    public var isScrollEnabled: Bool {
        set {
            overlayScrollView.isScrollEnabled = newValue
        }
        get {
            overlayScrollView.isScrollEnabled
        }
    }
    
    public var adjustedContentInset: UIEdgeInsets {
        return overlayScrollView.adjustedContentInset
    }
    
    public var additionalSafeAreaInsets: UIEdgeInsets = .zero
    
    public var contentSize: CGSize {
        overlayScrollView.contentSize
    }
    
    public override var backgroundColor: UIColor? {
        didSet {
            bottomView.backgroundColor = backgroundColor
            headerView.backgroundColor = backgroundColor
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        contentSize
    }
    
    // MARK: - UI
    // contains headerView + bottomView
    private var containerScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.scrollsToTop = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.clipsToBounds = false
        return scrollView
    }()
    
    // handles whole scroll logic
    private var overlayScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = .clear
        scrollView.layer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()
    
    private lazy var headerView: CollectionView = {
        let cv = CollectionView(type: .list)
        cv.isScrollEnabled = false
        return cv
    }()
    
    private let bottomView = ListsCollection.BottomPageContainerView()
    
    // MARK: - KVO
    
    private var headerKVO: NSKeyValueObservation?
    private var scrollKVO: NSKeyValueObservation?
    private var scrollOffsetKVO: NSKeyValueObservation?
    
    // MARK: - Other properties
    private let refreshAnimationDelay: TimeInterval = 1
    private let eps: CGFloat = 1 / UIScreen.main.scale
    private var isUpdatingScrollOffsetManually: Bool = false
    private var willScrollToTop: Bool = false
    
    private var pages: [Int: UIView] = [:]
    private var scrolls: [Int: UIScrollView] = [:]
    private var contentOffsets: [Int: CGFloat] = [:]
    private var cells: [ListsCollection.BottomPageModel] = []
    private var models: [CollectionViewModelProtocol] = []
    
    private var refresher: RefreshControl?
    private var headerViewHeight: NSLayoutConstraint?
    public var showBlur: Bool = true
    
    private var currentIndex: Int
    
    private var menuOptionsHeight: CGFloat {
        bottomView.menuOptionsHeight
    }
    
    public var showMenuOptionsSeparator: Bool = true {
        willSet {
            bottomView.menuOptionsView.separator.isHidden = !newValue
        }
    }
    
    public var menuOptions: MenuOptionsCollectionView {
        bottomView.menuOptionsView
    }
    
    // MARK: - Init
    public init(pageIndex index: Int = 0) {
        currentIndex = index
        super.init(frame: .zero)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Deinit
    deinit {
        headerKVO?.invalidate()
        scrollKVO?.invalidate()
        scrollOffsetKVO?.invalidate()
    }
    
    // MARK: - Set up
    public func setUpRefresher(refreshCallback: Action?) {
        #if !targetEnvironment(macCatalyst)
        if refresher == nil {
            refresher = RefreshControl()
            overlayScrollView.refreshControl = refresher
        }
        refresher?.refreshCallback = refreshCallback
        #endif
    }
    
    private func commonInit() {
        overlayScrollView.delegate = self
        bottomView.pagerDelegate = self
        containerScrollView.addGestureRecognizer(overlayScrollView.panGestureRecognizer)
        setUpHeaderObserver()
        
        addSubview(overlayScrollView)
        overlayScrollView.stickToSuperviewSafeEdges(.all)
        
        addSubview(containerScrollView)
        containerScrollView.stickToSuperviewSafeEdges(.all)
        
        containerScrollView.addSubview(headerView)
        headerView.stickToSuperviewEdges([.left, .right, .top])
        headerView.width(to: containerScrollView)
        headerViewHeight = headerView.height(0)
        
        containerScrollView.addSubview(bottomView)
        bottomView.stickToSuperviewEdges([.left, .right, .bottom])
        bottomView.top(to: headerView)
        bottomView.height(to: containerScrollView)
        bottomView.width(to: containerScrollView)
        
        bottomView.addSubview(menuOptions)
        menuOptions.stickToSuperviewEdges([.left, .right, .top])
    }
    
    // MARK: - Observers
    private func setUpHeaderObserver() {
        headerKVO = headerView.findChildren(UIScrollView.self).first?.observe(\.contentSize, changeHandler: { [weak self] scroll, change in
            guard let self = self else { return }
            self.headerViewHeight?.constant = scroll.contentSize.height
            
            if let offset = self.contentOffsets[self.currentIndex], offset > 0 {
                self.containerScrollView.contentOffset.y = self.bottomView.frame.minY
            }
            
            self.bottomView.setMenuOptionsVisible()
            self.updateBlur()
            
            if let currentScroll = self.scrolls[self.currentIndex] {
                self.updateOverlayScrollContentSize(with: currentScroll)
            }
        })
    }
    
    private func setUpObserversForPageScroll(_ scroll: UIScrollView) {
        // observe current scroll view content size to update overlay content size
        scrollKVO = scroll.observe(\.contentSize, changeHandler: { [weak self] scroll, change in
            guard let self = self else { return }
            self.updateOverlayScrollContentSize(with: scroll)
        })
        // observe current scroll view content offset to update overlay content offset when changes were triggered by system
        scrollOffsetKVO = scroll.observe(\.contentOffset, changeHandler: { [weak self] scroll, change in
            guard let self = self else { return }
            if !self.isUpdatingScrollOffsetManually {
                self.updateOverlayOffset()
            }
        })
    }
    
    private func updateOverlayScrollContentSize(with view: UIView?) {
        guard let view = view else { return }
        overlayScrollView.contentSize = getContentSize(for: view)
    }
    
    private func getContentSize(for view: UIView) -> CGSize {
        if let scroll = view as? UIScrollView {
            let bottomHeight = max(scroll.contentSize.height, bottomView.frame.height - menuOptionsHeight)
            return CGSize(width: scroll.contentSize.width,
                          height: bottomHeight + headerView.frame.height + menuOptionsHeight)
        } else {
            let bottomHeight = frame.height - menuOptionsHeight
            return CGSize(width: bottomView.frame.width,
                          height: bottomHeight + headerView.frame.height + menuOptionsHeight)
        }
    }
    
    // MARK: - Reload
    private func reload(
        models: [CollectionViewModelProtocol],
        header: CollectionViewModelProtocol?,
        selectorTitles: [String],
        animated: Bool
    ) {
        // header view
        headerView.reload(with: header, animated: animated)
        
        // bottom view
        if cells.count == models.count {
            cells.enumerated().forEach({ $1.reload(with: models[$0], animated: animated) })
        } else {
            cells = models.map({ ListsCollection.BottomPageModel(viewModel: $0) })
            bottomView.reload(cells: cells, selectorTitles: selectorTitles, animated: false)
            cells.enumerated().forEach({ scrolls[$0] = $1.getCellView()?.findChildren(UIScrollView.self).first })
            
            changePageOnTheNextRunLoopCycle()
            pageDidChange(currentIndex)
        }
        
        refresher?.isHidden = true
    }
    
    public func reload(with viewModel: CollectionViewModelProtocol?, animated: Bool) {
        // refresher state
        if overlayScrollView.isDragging {
            refresherState = .needStopRefresher
        } else {
            refresherState = .stoppingRefresh
            mainQueue(delay: refreshAnimationDelay) {
                self.refresher?.endRefreshing()
                self.refresherState = .default
            }
        }
        
        // reload state
        if overlayScrollView.contentOffset.y >= 0 {
            reloadState = .default
        } else {
            reloadState = .needReload(viewModel, animated)
            return
        }
        
        // internal reload
        guard let viewModel = viewModel else { return }
        let pagerViewModel = viewModel as? PagerViewModel ?? PagerViewModel(pages: [PageViewModel(title: nil, viewModel: viewModel)], header: nil)
        self.collectionViewModel = pagerViewModel
        self.models = pagerViewModel.pages.map { $0.viewModel }
        reload(models: pagerViewModel.pages.map { $0.viewModel }, header: pagerViewModel.header, selectorTitles: pagerViewModel.pages.compactMap { $0.title }, animated: animated)
    }
    
    
    // MARK: - CollectionViewProtocol
    public func setEditing(_ value: Bool) {
        pages[currentIndex]?.findChildren(CollectionView.self).first?.setEditing(value)
    }
    
    public func beginRefreshing() {
        pages[currentIndex]?.findChildren(CollectionView.self).first?.beginRefreshing()
    }
    
    public func orientationWillChange(newSize: CGSize) {
        bottomView.orientationWillChange(newSize: newSize)
    }
    
    public func scroll(to cell: CellViewModelProtocol) {
        let collectionView = pages[currentIndex]?.findChildren(CollectionView.self).first
        collectionView?.scroll(to: cell)
    }
    
    
    // MARK: - Helpers
    private func changePageOnTheNextRunLoopCycle() {
        RunLoop.main.perform { [self] in
            bottomView.pagerView.changePage(newIndex: currentIndex, animated: false)
        }
    }
    
    private func updateBlur() {
        var alpha: CGFloat = 0
        if showBlur {
            let dy = overlayScrollView.contentOffset.y - (bottomView.frame.minY - safeAreaInsets.top)
            alpha = dy / safeAreaInsets.top
        }
        if headerViewHeight?.constant == 0 {
            menuOptions.updateBlur(alpha: 1)
            menuOptions.transform = .identity.translatedBy(x: 0, y: -max(0, -overlayScrollView.contentOffset.y))
            self.refresher?.verticalOffset = menuOptionsHeight
        } else {
            menuOptions.transform = .identity
            menuOptions.updateBlur(alpha: alpha)
            self.refresher?.verticalOffset = 0
        }
    }
    
    private func updateOverlayOffset() {
        // when system updated current scroll view we recalculate content offset for overlay
        guard let scroll = scrolls[currentIndex], scroll.contentOffset.y > 0 else { return }
        overlayScrollView.contentOffset.y = scroll.contentOffset.y + bottomView.frame.minY
    }
    
    private func updateScrollOffset() {
        isUpdatingScrollOffsetManually = true
        scrolls[currentIndex]?.contentOffset.y = overlayScrollView.contentOffset.y - bottomView.frame.minY
        isUpdatingScrollOffsetManually = false
    }
    
}

// MARK: - UIScrollViewDelegate
extension ListsCollectionView: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        contentOffsets[currentIndex] = scrollView.contentOffset.y
        let topHeight = bottomView.frame.minY
        
        if topHeight - scrollView.contentOffset.y > eps {
            containerScrollView.contentOffset.y = willScrollToTop ? 0 : scrollView.contentOffset.y
            scrolls.forEach { $1.contentOffset.y = 0 }
            contentOffsets.removeAll()
        } else {
            containerScrollView.contentOffset.y = topHeight
            updateScrollOffset()
        }
        
        // delayed reload
        if scrollView.contentOffset.y >= 0,
           case .needReload(let viewModel, let animated) = reloadState,
           refresherState == .default {
            reload(with: viewModel, animated: animated)
        }
        
        // blur transparency
        updateBlur()
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard currentIndex < models.count else { return }
        (models[currentIndex] as? CollectionViewModel)?.scrollViewDidEndDecelerating(scrollView)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if refresherState == .needStopRefresher {
            refresherState = .stoppingRefresh
            mainQueue(delay: refreshAnimationDelay) {
                self.refresher?.endRefreshing()
                self.refresherState = .default
            }
        }
    }
    
    public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        willScrollToTop = false
    }
    
    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        willScrollToTop = overlayScrollView.contentOffset.y > 0
        return willScrollToTop
    }
    
}

// MARK: - PagerDelegate
extension ListsCollectionView: PagerDelegate {
    
    public func pageDidChange(_ index: Int) {
        currentIndex = index
        
        if let offset = contentOffsets[index] {
            overlayScrollView.contentOffset.y = offset
        } else {
            overlayScrollView.contentOffset.y = containerScrollView.contentOffset.y
        }
        
        if pages[index] == nil && index < cells.count {
            pages[currentIndex] = cells[index].getCellView()
        }
        
        if let scrollView = scrolls[currentIndex] {
            scrollView.panGestureRecognizer.require(toFail: overlayScrollView.panGestureRecognizer)
            scrollView.contentInsetAdjustmentBehavior = .never
            setUpObserversForPageScroll(scrollView)
            updateOverlayScrollContentSize(with: scrollView)
        }
    }
    
}
