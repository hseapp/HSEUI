import UIKit

final class BaseTableView: UITableView, BaseCollectionViewProtocol {
    
    // MARK: - Internal Properties
    
    var collectionDataSource: CollectionDataSource? {
        didSet {
            self.dataSource = collectionDataSource?.dataSource as? UITableViewDataSource
        }
    }

    var heightConstant: CGFloat = 0 {
        didSet {
            if heightConstant > 44 && heightConstant <= UIScreen.main.bounds.height {
                heightConstraint?.constant = heightConstant
                heightConstraint?.isActive = true
            }
            else {
                heightConstraint?.isActive = false
            }
        }
    }
    
    override var contentSize: CGSize {
        didSet {
            heightConstant = contentSize.height + adjustedContentInset.top + adjustedContentInset.bottom
        }
    }
    
    // MARK: - Private Properties

    private var listeners: [EventListener?] = []
    
    private var heightConstraint: NSLayoutConstraint?
    
    private weak var refresher: UIRefreshControl?
    
    private var disableLayout = false
    
    // MARK: - Init

    init() {
        super.init(frame: UIScreen.main.bounds, style: .plain)
        showsVerticalScrollIndicator = false
        allowsSelection = false
        separatorStyle = .none
        keyboardDismissMode = .onDrag
        backgroundColor = Color.Base.mainBackground
        
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
    
    // MARK: - Override UITableView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let offsetFromInit = -self.adjustedContentInset.top - contentOffset.y
        refreshControl?.frame.size.height = offsetFromInit
        if disableLayout { disableLayout = false; return }
        updateScrollEnabled()
    }
    
    override func addSubview(_ view: UIView) {
        if refresher == nil, let v = view as? UIRefreshControl {
            refresher = v
            super.addSubview(view)
            refreshControl = refresher
        }
        else {
            super.addSubview(view)
        }
    }
    
    override func adjustedContentInsetDidChange() {
        super.adjustedContentInsetDidChange()
        heightConstant = contentSize.height + adjustedContentInset.top + adjustedContentInset.bottom
    }
    
    override func reloadData() {
        super.reloadData()
        self.delegate?.scrollViewDidScroll?(self)
    }
    
    // MARK: - Internal Methods

    func bind(to viewModel: CollectionViewModelProtocol?) {
        delegate = viewModel as? UITableViewDelegate
        listeners = []
        listeners.append(viewModel?.setCellVisible.listen { [weak self] (indexPath: IndexPath) in
            guard let self = self else { return }
            self.scrollToRow(at: indexPath, at: .middle, animated: true)
        })
    }

    func reload(with viewModel: CollectionViewModelProtocol?) {
        bind(to: viewModel)
        dataSource = viewModel as? UITableViewDataSource
        reloadData()
    }
    
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
    
    // MARK: - Private Properties
    
    private func updateScrollEnabled() {
        let delta = round(self.contentSize.height + self.adjustedContentInset.top + self.adjustedContentInset.bottom - bounds.height)
        let newValue = round(delta) > 0 || self.contentOffset.y > self.adjustedContentInset.top || refresher != nil
        disableLayout = true
        if newValue != isScrollEnabled { self.isScrollEnabled = newValue }
    }

}
