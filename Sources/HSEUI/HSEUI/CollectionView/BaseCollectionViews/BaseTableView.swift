import UIKit

class BaseTableView: UITableView, BaseCollectionViewProtocol {
    
    private var heightConstraint: NSLayoutConstraint?

    var heightConstant: CGFloat = 0 {
        didSet {
            if heightConstant > 44 && heightConstant <= UIScreen.main.bounds.height {
                heightConstraint?.constant = heightConstant
                heightConstraint?.isActive = true
            } else {
                heightConstraint?.isActive = false
            }
        }
    }
    
    override var contentSize: CGSize {
        didSet {
            heightConstant = contentSize.height + adjustedContentInset.top + adjustedContentInset.bottom
            if oldValue != self.contentSize { contentSizeChanged?() }
        }
    }
    
    override func adjustedContentInsetDidChange() {
        super.adjustedContentInsetDidChange()
        heightConstant = contentSize.height + adjustedContentInset.top + adjustedContentInset.bottom
    }
    
    private var contentSizeChanged: (() -> ())?

    private var listeners: [EventListener?] = []
    
    private lazy var initialContentOffset: CGPoint = {
        return self.contentOffset
    }()
    
    public var collectionDataSource: CollectionDataSource? {
        didSet {
            self.dataSource = collectionDataSource?.dataSource as? UITableViewDataSource
        }
    }

    init() {
        super.init(frame: UIScreen.main.bounds, style: .plain)
        showsVerticalScrollIndicator = false
        allowsSelection = false
        separatorStyle = .none
        keyboardDismissMode = .onDrag
        self.backgroundColor = Color.Base.mainBackground
        heightConstraint = heightAnchor.constraint(equalToConstant: heightConstant)
        heightConstraint?.priority = UILayoutPriority(925)
        heightConstraint?.isActive = false
        contentInsetAdjustmentBehavior = .always
        #if !targetEnvironment(macCatalyst)
        if #available(iOS 15.0, *) {
            self.sectionHeaderTopPadding = 0
        }
        #endif
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(to viewModel: CollectionViewModelProtocol?) {
        delegate = viewModel as? UITableViewDelegate
        listeners = []
        listeners.append(viewModel?.setCellVisible.listen { [weak self] (indexPath: IndexPath) in
            guard let self = self else { return }
            self.scrollToRow(at: indexPath, at: .middle, animated: true)
        })
        contentSizeChanged = { [weak self] in
            guard let self = self else { return }
            viewModel?.contentSizeChanged.raise(data: self.contentSize)
        }
    }

    func reload(with viewModel: CollectionViewModelProtocol?) {
        bind(to: viewModel)
        dataSource = viewModel as? UITableViewDataSource
        reloadData()
    }
    
    override func reloadData() {
        super.reloadData()
        self.delegate?.scrollViewDidScroll?(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        refreshControl?.frame = CGRect(x: 0, y: 0, width: frame.width, height: contentOffset.y)
        if disableLayout { disableLayout = false; return }
        updateScrollEnabled()
    }
    
    private weak var refresher: UIRefreshControl?
    
    override func addSubview(_ view: UIView) {
        if refresher == nil, let v = view as? UIRefreshControl {
            refresher = v
            super.addSubview(view)
            refreshControl = refresher
        } else {
            super.addSubview(view)
        }
    }
    
    private var disableLayout = false
    private func updateScrollEnabled() {
        let delta = round(self.contentSize.height + self.adjustedContentInset.top + self.adjustedContentInset.bottom - bounds.height)
        let newValue = round(delta) != 0 || self.contentOffset.y > self.adjustedContentInset.top || refresher != nil
        disableLayout = true
        if newValue != isScrollEnabled { self.isScrollEnabled = newValue }
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        updateScrollEnabled()
//        super.touchesBegan(touches, with: event)
//    }
//
//    override func touchesShouldBegin(_ touches: Set<UITouch>, with event: UIEvent?, in view: UIView) -> Bool {
//        return super.touchesShouldBegin(touches, with: event, in: view)
//    }
//
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for touch in touches {
//            let tr = touch.location(in: self).y - touch.previousLocation(in: self).y
//            if tr > 0 && self.contentOffset.y <= initialContentOffset.y && refresher == nil {
//                self.contentOffset.y = initialContentOffset.y
//                isScrollEnabled = false
//            } else {
//                updateScrollEnabled()
//            }
//        }
//        super.touchesMoved(touches, with: event)
//    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesEnded(touches, with: event)
//        updateScrollEnabled()
//    }
//
//    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesCancelled(touches, with: event)
//        updateScrollEnabled()
//    }
    
    func insertItems(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        insertRows(at: indexPaths, with: animation)
    }
    
    func deleteItems(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        deleteRows(at: indexPaths, with: animation)
    }
    
    func scrollToTop() {
        // в расписании numberOfRows(inSection: 0) > 0 == false
        if contentOffset != .zero,
           let firstSection = (0..<numberOfSections).first(where: { numberOfRows(inSection: $0) > 0 }) {
            scrollToRow(at: .init(row: 0, section: firstSection), at: .top, animated: true)
        }
    }

    func scroll(to indexPath: IndexPath) {
        scrollToRow(at: indexPath, at: .middle, animated: true)
    }

    func reloadItems(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        reloadRows(at: indexPaths, with: animation)
    }
    
    func reloadSections(_ sections: [Int], with animation: UITableView.RowAnimation) {
        reloadSections(IndexSet(sections), with: animation)
    }
    
    func beginRefreshing() {
        guard let refresher = refresher else { return }
        let delta = refresher.bounds.height
        
        self.setContentOffset(CGPoint(x: 0, y: -self.adjustedContentInset.top - delta), animated: true)
        refresher.beginRefreshing()
    }

}
