import UIKit

open class CellView: UIView {
    
    // MARK: - Public Properties
    
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
            }
            else {
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
            }
            else {
                widthConstraint = widthAnchor.constraint(equalToConstant: widthConstant)
                widthConstraint?.isActive = true
                widthConstraint?.priority = UILayoutPriority(999)
            }
        }
    }
    
    public var useChevron: Bool = false

    open override var backgroundColor: UIColor? {
        didSet {
            if useChevron, let cell = self.superview?.superview as? UITableViewCell {
                cell.backgroundColor = backgroundColor
            }
        }
    }
    
    // MARK: - Private Properties

    private var isSelected: Bool = false
    private var isSelectedUI: Bool = false
    private var selectionCallback: ((Bool) -> Bool)?
    
    private var tapCallback: Action?
    
    // MARK: - Init

    public required init() {
        super.init(frame: .zero)
        backgroundColor = Color.Base.mainBackground
        setUpView()
        commonInit()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Open Methods

    open func commonInit() { /* Override in subclass */ }

    open func setUpView() { /* Override in subclass */ }

    open func touchBegan() { /* Override in subclass */ }

    open func touchEnded() { /* Override in subclass */ }
    
    open func setSelectedUI(selected: Bool) { /* Override in subclass */ }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard let delegate = self as? UIContextMenuInteractionDelegate else {
            return
        }
        
        if let cell = superview?.superview as? UITableViewCell {
            cell.addInteraction(UIContextMenuInteraction(delegate: delegate))
        }
        else {
            self.addInteraction(UIContextMenuInteraction(delegate: delegate))
        }
    }

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
                tapCallback?()
            }
            else {
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
    
    // MARK: - Public Methods
    
    public func configureTap(callback: Action?) {
        tapCallback = callback
        
        if tapCallback != nil {
            isAccessibilityElement = true
            accessibilityTraits.insert(.button)
        }
        else {
            accessibilityTraits.remove(.button)
        }
    }
    
    public func updateCollection(animated: Bool) {
        findSuperview(CollectionView.self)?.reload(with: nil, animated: animated)
    }
    
    public func configureSelectionCallback(callback: @escaping (Bool) -> Bool) {
        selectionCallback = callback
    }
    
    public func setSelected(selected: Bool, animated: Bool) {
        isSelected = selectionCallback?(selected) ?? false
        
        if isSelectedUI != isSelected {
            let block = { [weak self] in
                guard let self = self else { return }
                
                self.isSelectedUI = self.isSelected
                self.setSelectedUI(selected: self.isSelected)
            }
            
            animated ? UIView.animate(withDuration: 0.3) { block() } : block()
        }
    }
    
    // MARK: - Internal Methods
    
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

// MARK: - Accessibility Helpers

extension CellView {
    
    override open var accessibilityLabel: String? {
        get {
            return super.accessibilityLabel ?? getAllSubviewsText(for: self)
        }
        set {
            super.accessibilityLabel = newValue
        }
    }
    
    private func getAllSubviewsText(for view: UIView) -> String {
        var str = ""
        
        view.subviews.forEach {
            if !($0 is CellView) {
                let accessLabel = $0.accessibilityLabel ?? ""
                str += accessLabel
                str = accessLabel.isEmpty ? str : str + ". "
            }
            
            let subviewsText = getAllSubviewsText(for: $0)
            str += subviewsText
        }
        
        return str
    }
    
}
