import UIKit

open class CellView: UIView, CellViewProtocol {

    private var isSelected: Bool = false

    private var isSelectedUI: Bool = false

    private var listeners: [EventListener] = []

    private var tapCallback: Action?

    private var _selectionCallback: ((Bool) -> Bool)?

    public var useChevron: Bool = false

    open override var backgroundColor: UIColor? {
        didSet {
            if useChevron, let cell = self.superview?.superview as? UITableViewCell {
                cell.backgroundColor = backgroundColor
            }
        }
    }

    public init() {
        super.init(frame: .zero)
        backgroundColor = Color.Base.mainBackground
        setUpView()
        commonInit()
        listeners.append(Event.other("UIViewTap\(hashValue)").listen { [weak self] in
            self?.tapCallback?()
        })
        //asdcasdc
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func commonInit() { }

    open func setUpView() { }

    open func setSelectedUI(selected: Bool) {}

    open func touchBegan() { }

    open func touchEnded() { }

    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        touchBegan()
        self.isSelectedUI = true
        UIView.animate(withDuration: 0.1) {
            self.setSelectedUI(selected: true)
        }
    }

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        touches.forEach { touch in
            if self.bounds.contains(touch.location(in: self)) {
                self.setSelected(selected: !self.isSelected, animated: true)
                Event.other("UIViewTap\(hashValue)").raise()
            } else {
                self.setSelected(selected: self.isSelected, animated: true)
            }
        }
        touchEnded()
    }

    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.setSelected(selected: self.isSelected, animated: true)
        touchEnded()
    }

    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let delegate = self as? UIContextMenuInteractionDelegate {
            if let cell = superview?.superview as? UITableViewCell {
                cell.addInteraction(UIContextMenuInteraction(delegate: delegate))
            } else {
                self.addInteraction(UIContextMenuInteraction(delegate: delegate))
            }
        }
    }

    // MARK: easy set size while reusing
    public var heightConstraint: NSLayoutConstraint?

    public var heightConstant: CGFloat? {
        didSet {
            guard let heightConstant = heightConstant else {
                heightConstraint?.isActive = false
                heightConstraint = nil
                return
            }
            if let heightConstraint = heightConstraint {
                heightConstraint.constant = heightConstant
            } else {
                heightConstraint = height(heightConstant)
                heightConstraint?.priority = UILayoutPriority(999)
            }
        }
    }

    public var widthConstraint: NSLayoutConstraint?

    public var widthConstant: CGFloat? {
        didSet {
            guard let widthConstant = widthConstant else {
                widthConstraint?.isActive = false
                widthConstraint = nil
                return
            }
            if let widthConstraint = widthConstraint {
                widthConstraint.constant = widthConstant
            } else {
                widthConstraint = widthAnchor.constraint(equalToConstant: widthConstant)
                widthConstraint?.isActive = true
                widthConstraint?.priority = UILayoutPriority(999)
            }
        }
    }
    
    public func updateCollection(animated: Bool) {
        findSuperview(CollectionView.self)?.reload(with: nil, animated: animated)
    }
    
    func highlight(backgroundColor: UIColor = Color.Base.mainBackground,
                   with highlightColor: UIColor = Color.Base.selection,
                   overallDuration: TimeInterval = 1.0,
                   completion: Action?) {
        
        UIView.transition(with: self,
                          duration: overallDuration / 2,
                          options: .transitionCrossDissolve) {
            
            self.backgroundColor = highlightColor
        } completion: { _ in
            
            UIView.transition(with: self,
                              duration: overallDuration / 2,
                              options: .transitionCrossDissolve) {
                
                self.backgroundColor = backgroundColor
                completion?()
            }
        }
    }

}

// MARK: - Selectable
protocol Selectable {

    func setSelected(selected: Bool, animated: Bool)

    func configureSelectionCallback(callback: @escaping (Bool) -> Bool)

}

extension CellView: Selectable {

    public func setSelected(selected: Bool, animated: Bool) {
        let newSelected = _selectionCallback?(selected) ?? false
        if isSelected != newSelected {
            isSelected = newSelected
        }
        if isSelectedUI != newSelected {
            let block = {
                self.isSelectedUI = newSelected
                self.setSelectedUI(selected: newSelected)
            }
            if animated {
                UIView.animate(withDuration: 0.3) {
                    block()
                }
            } else {
                block()
            }
        }
    }

    public func configureSelectionCallback(callback: @escaping (Bool) -> Bool) {
        _selectionCallback = callback
    }

}

// MARK: - Tappable

protocol Tappable {
    func configureTap(callback: Action?)
}

extension CellView: Tappable {

    public func configureTap(callback: Action?) {
        tapCallback = callback
        
        if tapCallback != nil {
            isAccessibilityElement = true
            accessibilityTraits.insert(.button)
            accessibilityLabel = ""
            getAllSubviewsText(for: self)
            
        } else {
            isAccessibilityElement = false
            accessibilityTraits.remove(.button)
            
        }
    }
    
    private func getAllSubviewsText(for view: UIView) {
        view.subviews.forEach {
            accessibilityLabel! += $0.accessibilityLabel ?? "" + " "
            getAllSubviewsText(for: $0)
        }
    }

}
