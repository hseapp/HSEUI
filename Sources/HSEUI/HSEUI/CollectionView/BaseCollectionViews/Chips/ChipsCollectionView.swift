import UIKit

// USE THIS FUCKING CHIPS SHIT ONLY FOR FULL-WIDTH VIEW

// MARK: - CustomCollectionViewDataSource

protocol CustomCollectionViewDataSource: AnyObject {
    func cells() -> [CellViewModelProtocol]
}

// MARK: - ChipsCollectionView

class ChipsCollectionView: UIScrollView, BaseCollectionViewProtocol {
    
    // MARK: - internal properties
    
    override var contentInset: UIEdgeInsets {
        get {
            return _contentInset
        }
        set {
            _contentInset = newValue
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    var spacing: CGFloat {
        set {
            _spacing = newValue
        }
        get {
            _spacing
        }
    }
    
    var collectionDataSource: CollectionDataSource? {
        didSet {
            dataSource = collectionDataSource?.dataSource as? CustomCollectionViewDataSource
        }
    }
    
    // MARK: - private properties

    private var _spacing: CGFloat = 8
    
    private var _contentInset: UIEdgeInsets = .init(top: 8, left: 16, bottom: 8, right: 16)
    
    private weak var dataSource: CustomCollectionViewDataSource?
    
    private var heightConstraint: NSLayoutConstraint?

    private var cellViews: [UIView] = []
    
    private var cache: [Int: CGSize] = [:]

    private var childConstraints: [Int: NSLayoutConstraint] = [:]
    
    // MARK: - init
    
    init() {
        super.init(frame: .zero)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - methods
    
    func commonInit() {
        backgroundColor = .clear
        heightConstraint = height(0)
    }
    
    func reloadData() {
        currentCells = dataSource?.cells() ?? []
        updateViews()
        layoutSubviews()
    }
    
    private var currentCells: [CellViewModelProtocol] = []

    private func updateViews() {
        for i in 0..<min(cellViews.count, currentCells.count) {
            if !currentCells[i].updateView(view: cellViews[i]) {
                let new = currentCells[i].initView()
                cellViews[i].removeFromSuperview()
                addSubview(new)
                cellViews[i] = new
            }
        }
        if cellViews.count < currentCells.count {
            for i in cellViews.count..<currentCells.count {
                let new = currentCells[i].initView()
                cellViews.append(new)
                addSubview(new)
            }
        }
        if currentCells.count < cellViews.count {
            for _ in currentCells.count..<cellViews.count {
                cellViews.last?.removeFromSuperview()
                cellViews.removeLast()
            }
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        heightConstraint?.constant = layoutHeight(for: frame.width)
        layout()
    }

    // this code works fine when we already know our total height
    private func layout() {
        let totalWidth = frame.width
        var x: CGFloat = contentInset.left
        var y: CGFloat = contentInset.top
        var last: UIView?
        for i in 0..<min(currentCells.count, cellViews.count) {
            let view = cellViews[i]
            let size: CGSize
            if let cached = cache[currentCells[i].id] {
                size = cached
            } else {
                if let c = childConstraints[currentCells[i].id] {
                    c.constant = frame.width - contentInset.left - contentInset.right
                } else {
                    let c = view.widthAnchor.constraint(lessThanOrEqualToConstant: frame.width - contentInset.left - contentInset.right)
                    c.isActive = true
                    childConstraints[currentCells[i].id] = c
                }
                view.layoutIfNeeded()
                size = view.frame.size
                cache[currentCells[i].id] = size
            }
            if x + size.width + contentInset.right > totalWidth {
                x = contentInset.left
                y = (last?.frame.maxY ?? 0) + spacing
                view.frame.origin = CGPoint(x: x, y: y)
            } else {
                view.frame.origin = CGPoint(x: x, y: y)
            }
            x = view.frame.maxX + spacing
            last = view
        }
    }

    // this code is 100% correct if given correct width
    private func layoutHeight(for width: CGFloat) -> CGFloat {
        let totalWidth = width
        var x: CGFloat = contentInset.left
        var y: CGFloat = contentInset.top

        var result: CGFloat = 0
        for i in 0..<min(currentCells.count, cellViews.count) {
            let view = cellViews[i]
            let size: CGSize
            if let cached = cache[currentCells[i].id] {
                size = cached
            } else {
                size = view.systemLayoutSizeFitting(CGSize(width: width - contentInset.left - contentInset.right, height: 0), withHorizontalFittingPriority: .required, verticalFittingPriority: .init(1))
                cache[currentCells[i].id] = size
            }
            if x + size.width + contentInset.right > totalWidth {
                x = contentInset.left + size.width + spacing
                y += size.height + spacing
            } else {
                x += size.width + spacing
            }
            result = max(result, y + size.height + contentInset.bottom)
        }
        return result
    }

}

// MARK: - protocol ParentBoundsWidthCatcher

extension ChipsCollectionView: ParentBoundsWidthCatcher {

    public func catchParentBounds(width: CGFloat) {
        heightConstraint?.constant = layoutHeight(for: width)
    }

}
