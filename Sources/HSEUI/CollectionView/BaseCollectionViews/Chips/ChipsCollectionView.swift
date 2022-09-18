import UIKit

// USE THIS FUCKING CHIPS SHIT ONLY FOR FULL-WIDTH VIEW

// MARK: - CustomCollectionViewDataSource

protocol CustomCollectionViewDataSource: AnyObject {
    func cells() -> [CellViewModelProtocol]
}

// MARK: - ChipsCollectionView

final class ChipsCollectionView: UIScrollView, BaseCollectionViewProtocol {
    
    // MARK: - Internal Properties
    
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
    
    // MARK: - Private Properties

    private var _spacing: CGFloat = 8
    private var _contentInset: UIEdgeInsets = .init(top: 8, left: 16, bottom: 8, right: 16)
    
    private var heightConstraint: NSLayoutConstraint?
    private var childConstraints: [Int: NSLayoutConstraint] = [:]
    
    private weak var dataSource: CustomCollectionViewDataSource?
    private var currentCells: [CellViewModelProtocol] = []
    private var cellViews: [UIView] = []
    private var cache: [Int: CGSize] = [:]

    
    // MARK: - init
    
    init() {
        super.init(frame: .zero)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Internal Methods
    
    override func layoutSubviews() {
        super.layoutSubviews()
        heightConstraint?.constant = layoutHeight(for: frame.width)
        layout()
    }
    
    func commonInit() {
        backgroundColor = .clear
        heightConstraint = height(0)
    }
    
    func reloadData() {
        currentCells = dataSource?.cells() ?? []
        updateViews()
        layoutSubviews()
    }
    
    // MARK: - Private Methods

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
            for i in cellViews.count ..< currentCells.count {
                let new = currentCells[i].initView()
                cellViews.append(new)
                addSubview(new)
            }
        }
        
        if currentCells.count < cellViews.count {
            for _ in currentCells.count ..< cellViews.count {
                cellViews.last?.removeFromSuperview()
                cellViews.removeLast()
            }
        }
    }

    // this code works fine when we already know our total height
    private func layout() {
        let totalWidth = frame.width
        guard totalWidth > 0 else { return }
        
        var x = contentInset.left
        var y = contentInset.top
        var maxHeightInRow: CGFloat = 0
        
        for i in 0 ..< min(currentCells.count, cellViews.count) {
            let view = cellViews[i]
            let size: CGSize
            
            if let c = childConstraints[currentCells[i].id] {
                c.constant = frame.width - contentInset.left - contentInset.right
            }
            else {
                let c = view.widthAnchor.constraint(lessThanOrEqualToConstant: frame.width - contentInset.left - contentInset.right)
                c.isActive = true
                childConstraints[currentCells[i].id] = c
            }
            
            view.layoutIfNeeded()
            size = view.frame.size
            
            if x + size.width + contentInset.right > totalWidth {
                x = contentInset.left
                y += maxHeightInRow + spacing
                maxHeightInRow = 0
                view.frame.origin = CGPoint(x: x, y: y)
            }
            else {
                view.frame.origin = CGPoint(x: x, y: y)
            }
            
            maxHeightInRow = max(maxHeightInRow, size.height)
            x = view.frame.maxX + spacing
        }
    }

    // this code is 100% correct if given correct width
    private func layoutHeight(for width: CGFloat) -> CGFloat {
        let totalWidth = width
        guard totalWidth > 0 else { return 0 }
        
        var x = contentInset.left
        var y = contentInset.top
        var result: CGFloat = 0
        var maxHeightInRow: CGFloat = 0
        
        for i in 0 ..< min(currentCells.count, cellViews.count) {
            let view = cellViews[i]
            let size: CGSize
            
            if let c = childConstraints[currentCells[i].id] {
                c.constant = totalWidth - contentInset.left - contentInset.right
            }
            else {
                let c = view.widthAnchor.constraint(lessThanOrEqualToConstant: totalWidth - contentInset.left - contentInset.right)
                c.isActive = true
                childConstraints[currentCells[i].id] = c
            }
            
            view.layoutIfNeeded()
            size = view.frame.size
            
            if x + size.width + contentInset.right > totalWidth {
                x = contentInset.left + size.width + spacing
                y += maxHeightInRow + spacing
                maxHeightInRow = 0
            }
            else {
                x += size.width + spacing
            }
            
            maxHeightInRow = max(maxHeightInRow, size.height)
            result = max(result, y + size.height + contentInset.bottom)
        }
        
        return result
    }

}

// MARK: - Protocol ParentBoundsWidthCatcher

protocol ParentBoundsWidthCatcher {
    func catchParentBounds(width: CGFloat)
}

extension ChipsCollectionView: ParentBoundsWidthCatcher {

    public func catchParentBounds(width: CGFloat) {
        heightConstraint?.constant = layoutHeight(for: width)
    }

}

extension UIView {

    func throwWidth(_ width: CGFloat) {
        guard width != 0 else { return }
        
        subviews.forEach { view in
            if let catcher = view as? ParentBoundsWidthCatcher {
                catcher.catchParentBounds(width: width)
            }
            else {
                view.throwWidth(width)
            }
        }
    }
    
}
