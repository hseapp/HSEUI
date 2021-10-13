import UIKit
import HSEUI

// MARK: - namespace
enum ListsCollection { }

// MARK: - CollectionWithHeader main class
class ListsCollectionView: UIView, CollectionViewProtocol {
    
    var type: CollectionView.CollectionType { return .pager }
    
    // MARK: - States
    enum ReloadState {
        case `default`
        case needReload(CollectionViewModelProtocol?, Bool)
    }
    
    enum RefresherState {
        case `default`
        case needStopRefresher
        case stoppingRefresh
    }
    
    private var reloadState: ReloadState = .default
    
    private var refresherState: RefresherState = .default
    
    // MARK: - CollectionViewProtocol
    var isEditable: Bool {
        pages[currentIndex]?.findChildren(CollectionView.self).first?.isEditable ?? false
    }
    
    var adjustedContentInset: UIEdgeInsets {
        return overlayScrollView.adjustedContentInset
    }
    
    var isScrollEnabled: Bool {
        set {
            overlayScrollView.isScrollEnabled = newValue
        }
        get {
            overlayScrollView.isScrollEnabled
        }
    }
    
    var additionalSafeAreaInsets: UIEdgeInsets = .zero
    
    override var backgroundColor: UIColor? {
        didSet {
            containerScrollView.backgroundColor = backgroundColor
        }
    }
    
    func scroll(to cell: CellViewModel) {
        let collectionView = pages[currentIndex]?.findChildren(CollectionView.self).first
        collectionView?.scroll(to: cell)
    }
    
    // MARK: - UI
    // contains headerView + bottomView
    private var containerScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.scrollsToTop = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
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
        setUpScroll(for: cv)
        return cv
    }()
    
    private let bottomView: ListsCollection.BottomPagePresentable = ListsCollection.BottomPageContainerView()
    
    // MARK: - other properties
    private let refreshAnimationDelay: TimeInterval = 1
    
    // cell views
    var pages: [Int: UIView] = [:]
    
    // scrolls of cell views
    var scrolls: [Int: UIScrollView] = [:]
    
    private var menuOptionsHeight: CGFloat {
        bottomView.menuOptionsHeight
    }
    
    private var refresher: RefreshControl?
    
    private var headerViewHeightConstraint: NSLayoutConstraint?
    
    private var topConstraint: NSLayoutConstraint?
    
    private var currentIndex: Int = 0
    
    private let eps: CGFloat = 1 / UIScreen.main.scale
    
    private var contentOffsets: [Int: CGFloat] = [:]
    
    private var cells: [ListsCollection.BottomPageModel] = []
    
    private var models: [CollectionViewModelProtocol] = []
    
    // MARK: - init
    init() {
        super.init(frame: .zero)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - deinit
    deinit {
        pages.forEach({ removeObserver(for: $1) })
        removeObserver(for: headerView)
    }
    
    // MARK: - life cycle
    override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        topConstraint?.constant = safeAreaInsets.top
        refresher?.verticalOffset = safeAreaInsets.top
        pages.forEach({
            $1.findChildren(CollectionView.self).first?.additionalSafeAreaInsets.top = safeAreaInsets.top
        })
    }
    
    // MARK: - set up
    func setUpRefresher(refreshCallback: Action?) {
        #if !targetEnvironment(macCatalyst)
        if refresher == nil {
            refresher = RefreshControl()
            refresher?.verticalOffset = safeAreaInsets.top
            overlayScrollView.refreshControl = refresher
        }
        refresher?.refreshCallback = refreshCallback
        #endif
    }
    
    private func setUpScroll(for view: UIView?) {
        if let scrollView = view?.findChildren(UIScrollView.self).first {
            scrollView.panGestureRecognizer.require(toFail: overlayScrollView.panGestureRecognizer)
            scrollView.contentInsetAdjustmentBehavior = .never
            scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize), options: .new, context: nil)
        }
    }
    
    private var orientationEvent: EventListener?
    
    private func commonInit() {
        overlayScrollView.delegate = self
        bottomView.pagerDelegate = self
        containerScrollView.addGestureRecognizer(overlayScrollView.panGestureRecognizer)
        
        addSubview(overlayScrollView)
        overlayScrollView.stickToSuperviewEdges(.all)
        
        addSubview(containerScrollView)
        containerScrollView.stickToSuperviewEdges(.all)
        
        containerScrollView.addSubview(headerView)
        topConstraint = headerView.stickToSuperviewEdges([.left, .right, .top])?.top
        headerView.width(to: containerScrollView)
        headerViewHeightConstraint = headerView.height(0)
        
        containerScrollView.addSubview(bottomView)
        bottomView.stickToSuperviewEdges([.left, .right, .bottom])
        bottomView.top(to: headerView)
        bottomView.heightAnchor.constraint(equalTo: containerScrollView.heightAnchor).isActive = true
        bottomView.width(to: containerScrollView)
        
        orientationEvent = DeviceEvent.orientationDidChange.listen { [weak self] in
            // update content offset when orientation is changed
            guard let `self` = self else { return }
            self.scrollViewDidScroll(self.overlayScrollView)
        }
    }
    
    // MARK: - observers
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let obj = object as? UIScrollView, keyPath == #keyPath(UIScrollView.contentSize) {
            // observe content size
            if let scroll = scrolls[currentIndex], obj == scroll {
                updateOverlayScrollContentSize(with: scroll)
            } else if let scroll = headerView.findChildren(UIScrollView.self).first, obj == scroll {
                headerViewHeightConstraint?.constant = scroll.contentSize.height
                
                if let offset = contentOffsets[currentIndex], offset > 0 {
                    let topHeight = bottomView.frame.minY - safeAreaInsets.top
                    containerScrollView.contentOffset.y = topHeight + safeAreaInsets.top
                }
                
                bottomView.setMenuOptionsVisible()
            }
        }
    }
    
    private func removeObserver(for view: UIView?) {
        view?.findChildren(UIScrollView.self).first?.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize))
    }
    
    private func updateOverlayScrollContentSize(with view: UIView?) {
        guard let view = view else { return }
        overlayScrollView.contentSize = getContentSize(for: view)
    }
    
    private func getContentSize(for view: UIView) -> CGSize {
        let headerViewHeight: CGFloat = headerView.frame.height + safeAreaInsets.top
        if let scroll = view as? UIScrollView {
            let bottomHeight = max(scroll.contentSize.height, safeBounds.height - menuOptionsHeight)
            return CGSize(width: scroll.contentSize.width,
                          height: bottomHeight + headerViewHeight + menuOptionsHeight + safeAreaInsets.bottom)
        } else {
            let bottomHeight = safeBounds.height - menuOptionsHeight
            return CGSize(width: bottomView.frame.width,
                          height: bottomHeight + headerViewHeight + menuOptionsHeight + safeAreaInsets.bottom)
        }
    }
    
    // MARK: - reload
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
            pageDidChange(currentIndex)
            updateScrolls()
            
            // TODO: - fix
            if header == nil {
                cells.enumerated().forEach({ $1.reload(with: models[$0], animated: false) })
            }
        }
        
        refresher?.isHidden = true
    }
    
    func reload(with viewModel: CollectionViewModelProtocol?, animated: Bool) {
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
        guard let pagerViewModel = viewModel as? PagerViewModel else { return }
        self.models = pagerViewModel.pages.map { $0.viewModel }
        reload(models: pagerViewModel.pages.map { $0.viewModel }, header: pagerViewModel.header, selectorTitles: pagerViewModel.pages.compactMap { $0.title }, animated: animated)
    }
    
    // MARK: - helpers
    func setEditing(_ value: Bool) {
        pages[currentIndex]?.findChildren(CollectionView.self).first?.setEditing(value)
    }
    
    func beginRefreshing() {
        pages[currentIndex]?.findChildren(CollectionView.self).first?.beginRefreshing()
    }
    
    func orientationWillChange(newSize: CGSize) {
        bottomView.orientationWillChange(newSize: newSize)
    }
    
    func updateScrolls() {
        scrolls.forEach({ removeObserver(for: $1) })
        cells.enumerated().forEach({ scrolls[$0] = $1.getCellView()?.findChildren(UIScrollView.self).first })
        scrolls.forEach({ setUpScroll(for: $1) })
    }

}

// MARK: - UIScrollViewDelegate
extension ListsCollectionView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        contentOffsets[currentIndex] = scrollView.contentOffset.y
        let topHeight = bottomView.frame.minY - safeAreaInsets.top

        if topHeight - scrollView.contentOffset.y > eps {
            containerScrollView.contentOffset.y = scrollView.contentOffset.y
            scrolls.forEach({
                var offsetY: CGFloat = 0
                if $0 != currentIndex {
                    offsetY = min(topHeight - containerScrollView.contentOffset.y, 0)
                }
                $1.contentOffset.y = offsetY
                $1.contentInset = .zero
            })
            contentOffsets.removeAll()
        } else {
            containerScrollView.contentOffset.y = topHeight + safeAreaInsets.top
            scrolls[currentIndex]?.contentOffset.y = scrollView.contentOffset.y - containerScrollView.contentOffset.y
            scrolls.forEach ({
                if contentOffsets[$0] == nil {
                    $1.contentOffset.y = -safeAreaInsets.top
                }
                $1.contentInset = safeAreaInsets
            })
        }
        
        // menu options offset
        if topHeight - scrollView.contentOffset.y > eps {
            bottomView.menuOptionsTop?.constant = 0
        } else {
            let dy = scrollView.contentOffset.y - topHeight + 2 * safeAreaInsets.top
            bottomView.menuOptionsTop?.constant = min(dy, safeAreaInsets.top)
        }

        // delayed reload
        if scrollView.contentOffset.y >= 0,
           case .needReload(let viewModel, let animated) = reloadState,
           refresherState == .default {
            reload(with: viewModel, animated: animated)
        }

        // blur transparency
        let dy = scrollView.contentOffset.y - (topHeight - safeAreaInsets.top)
        let r = dy / safeAreaInsets.top
        bottomView.menuOptionsView.updateBlur(alpha: r)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard currentIndex < models.count else { return }
        (models[currentIndex] as? CollectionViewModel)?.scrollViewDidEndDecelerating(scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if refresherState == .needStopRefresher {
            refresherState = .stoppingRefresh
            mainQueue(delay: refreshAnimationDelay) {
                self.refresher?.endRefreshing()
                self.refresherState = .default
            }
        }
    }
    
}

// MARK: - PagerDelegate
extension ListsCollectionView: PagerDelegate {

    func pageDidChange(_ index: Int) {
        currentIndex = index

        if let offset = contentOffsets[index] {
            overlayScrollView.contentOffset.y = offset
        } else {
            let topHeight = bottomView.frame.minY - safeAreaInsets.top
            var offset: CGFloat
            if topHeight - containerScrollView.contentOffset.y > eps {
                offset = containerScrollView.contentOffset.y
            } else {
                offset = containerScrollView.contentOffset.y - safeAreaInsets.top
            }
            overlayScrollView.contentOffset.y = offset
            contentOffsets[index] = offset
        }

        if pages[index] == nil && index < cells.count {
            pages[currentIndex] = cells[index].getCellView()
        }

        if let view = scrolls[currentIndex] {
            updateOverlayScrollContentSize(with: view)
        }
    }

}
