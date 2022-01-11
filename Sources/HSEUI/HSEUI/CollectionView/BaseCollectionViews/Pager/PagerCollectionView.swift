import UIKit

public protocol PagerPresentable: UIView {
    var currentIndex: Int { get }
    var pagerDelegate: PagerDelegate? { set get }
    
    func changePage(newIndex: Int, animated: Bool)
}

public protocol PagerDelegate: AnyObject {
    func pageDidChange(_ index: Int)
}

class PagerCollectionView: UIView, BaseCollectionViewProtocol, PagerPresentable {
    
    enum State {
        case changingOrientation
        case `default`
    }
    
    var contentSize: CGSize {
        return scrollView.contentSize
    }
    
    var contentOffset: CGPoint {
        return scrollView.contentOffset
    }
    
    override var backgroundColor: UIColor? {
        didSet {
            scrollView.backgroundColor = backgroundColor
        }
    }
    
    var contentInset: UIEdgeInsets {
        set {
            scrollView.contentInset = newValue
        }
        get {
            scrollView.contentInset
        }
    }
    
    private weak var dataSource: CustomCollectionViewDataSource?
    
    var collectionDataSource: CollectionDataSource? {
        didSet {
            dataSource = collectionDataSource?.dataSource as? CustomCollectionViewDataSource
        }
    }
    
    var currentIndex: Int = 0
    
    weak var pagerDelegate: PagerDelegate?
    
    private var state: State = .default

    private lazy var scrollView: PagerView = {
        let cv = PagerView()
        cv.isPagingEnabled = true
        cv.backgroundColor = Color.Base.mainBackground
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        return cv
    }()

    private lazy var container: UIView = .init()
    
    private var eventListener: EventListener?

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
    
    private func commonInit() {
        backgroundColor = Color.Collection.table
        scrollView.delegate = self
        
        addSubview(container)
        container.stickToSuperviewEdges(.all)
        
        container.addSubview(scrollView)
        scrollView.stickToSuperviewEdges(.all)
        
    }
    
    func changePage(newIndex: Int, animated: Bool) {
        scrollView.setContentOffset(CGPoint(x: CGFloat(newIndex) * frame.width, y: scrollView.contentOffset.y), animated: animated)
    }

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

}

extension PagerCollectionView: UIScrollViewDelegate {
    
    private func getIndex(for offset: CGFloat) -> Int {
        guard frame.width > 0 else { return 0 }
        Int((offset + frame.width / 2) / frame.width)
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
