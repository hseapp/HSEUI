import UIKit

public protocol PagerPresentable: UIView {
    var currentIndex: Int { get }
    var pagerDelegate: PagerDelegate? { set get }
    
    func changePage(newIndex: Int, animated: Bool)
}

public protocol PagerDelegate: AnyObject {
    func pageDidChange(_ index: Int)
}

final class PagerCollectionView: UIView, BaseCollectionViewProtocol, PagerPresentable {
    
    // MARK: - Private Types
    
    private enum State {
        case changingOrientation
        case `default`
    }
    
    // MARK: - Internal Properties
    
    weak var pagerDelegate: PagerDelegate?
    var currentIndex: Int = 0
    
    var contentSize: CGSize {
        return scrollView.contentSize
    }
    
    var contentOffset: CGPoint {
        return scrollView.contentOffset
    }
    
    var contentInset: UIEdgeInsets {
        set {
            scrollView.contentInset = newValue
        }
        get {
            scrollView.contentInset
        }
    }
    
    var collectionDataSource: CollectionDataSource? {
        didSet {
            dataSource = collectionDataSource?.dataSource as? CustomCollectionViewDataSource
        }
    }
    
    override var backgroundColor: UIColor? {
        didSet {
            scrollView.backgroundColor = backgroundColor
        }
    }
    
    // MARK: - Private Properties
    
    private var state: State = .default
    private var eventListener: EventListener?
    private weak var dataSource: CustomCollectionViewDataSource?

    private lazy var container: UIView = .init()
    
    private lazy var scrollView: PagerView = {
        let pagerView = PagerView()
        pagerView.isPagingEnabled = true
        pagerView.backgroundColor = Color.Base.mainBackground
        pagerView.showsHorizontalScrollIndicator = false
        pagerView.showsVerticalScrollIndicator = false
        return pagerView
    }()
    
    // MARK: - Init

    init() {
        super.init(frame: .zero)
        
        eventListener = DeviceEvent.orientationDidChange.listen { [weak self] in
            guard let `self` = self else { return }
            let offset: CGFloat = CGFloat(self.currentIndex) * self.frame.width
            self.scrollView.setContentOffset(.init(x: offset, y: 0), animated: true)
            self.state = .default
        }
        
        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Internal Methods

    func reloadData() {
        guard let cells = dataSource?.cells() else { return }
        var subviewsOptional: [UIView?] = scrollView.subviews
        
        while subviewsOptional.count > cells.count {
            subviewsOptional.last??.removeFromSuperview()
            subviewsOptional.removeLast()
        }
        
        while cells.count > subviewsOptional.count {
            subviewsOptional.append(nil)
        }
        
        for i in 0 ..< cells.count {
            let cell = cells[i]
            if !cell.updateView(view: subviewsOptional[i]) {
                let newView = cell.initView()
                scrollView.addSubview(newView)
            }
        }
        
        scrollView.updateSubviews()
    }
    
    func orientationWillChange(newSize: CGSize) {
        state = .changingOrientation
    }
    
    func scrollToTop() {
        changePage(newIndex: 0, animated: true)
    }
    
    func changePage(newIndex: Int, animated: Bool) {
        scrollView.setContentOffset(CGPoint(x: CGFloat(newIndex) * frame.width, y: scrollView.contentOffset.y), animated: animated)
    }
    
    // MARK: - Private Methods
    
    private func commonInit() {
        backgroundColor = Color.Collection.table
        scrollView.delegate = self
        
        addSubview(container)
        container.stickToSuperviewEdges(.all)
        
        container.addSubview(scrollView)
        scrollView.stickToSuperviewEdges(.all)
    }

}

// MARK: - Protocol UIScrollViewDelegate

extension PagerCollectionView: UIScrollViewDelegate {
    
    private func getIndex(for offset: CGFloat) -> Int {
        guard frame.width > 0 else { return 0 }
        return Int((offset + frame.width / 2) / frame.width)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard state == .default else { return }
        let newIndex: Int = getIndex(for: scrollView.contentOffset.x)
        if newIndex != currentIndex {
            pagerDelegate?.pageDidChange(newIndex)
            currentIndex = newIndex
        }
    }
    
}
