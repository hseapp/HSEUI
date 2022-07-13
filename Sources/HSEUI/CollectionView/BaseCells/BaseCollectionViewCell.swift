import UIKit

class BaseCollectionViewCell<T>: UICollectionViewCell where T: UIView {
    
    weak var currentViewModel: CellViewModelItem?
    
    private var view: T
    
    override init(frame: CGRect) {
        view = T.init()
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        backgroundColor = .clear
        
        contentView.removeFromSuperview()
        
        addSubview(view)
        view.stickToSuperviewEdges([.left, .top])
        
        let const = view.bottom()
        const.priority = UILayoutPriority(999)
        let const2 = view.trailing()
        const2.priority = UILayoutPriority(999)
        
    }
    
}

extension BaseCollectionViewCell: BaseCellProtocol {
    
    func voiceOverView() -> UIView { return self }
    
    func updateConfigurator<C>(with configurator: C) where C : CellViewConfiguratorProtocol {
        if view as? C.T != nil {
            configurator.configureView?(view as! C.T)
            (view as? CellView)?.useChevron = configurator.useChevron ?? (configurator.tapCallback != nil)
            (view as? Tappable)?.configureTap(callback: configurator.tapCallback)
        }
    }
    
    func setSelected(_ value: Bool) {
        (view as? Selectable)?.setSelected(selected: value, animated: true)
    }
    
    func setSelectionBlock(_ block: @escaping (Bool) -> Bool) {
        (view as? Selectable)?.configureSelectionCallback(callback: block)
    }
    
    func setWidth(_ value: CGFloat) {
        (view as? CellView)?.widthConstant = value
        (view as? CellView)?.widthConstraint?.priority = .required
    }
    
    func setHeight(_ value: CGFloat) {
        (view as? CellView)?.heightConstant = value
        (view as? CellView)?.heightConstraint?.priority = .required
    }
    
    func apply<U: UIView>(_ block: (U) -> ()) {
        if (view as? U) != nil {
            block(view as! U)
        }
    }
    
    func getCellView() -> UIView {
        return view
    }
    
}

class BaseCollectionReusableView<T>: UICollectionReusableView where T: UIView {
    
    var view: T
    
    var configureView: ((T) -> ())? {
        didSet {
            configureView?(view)
        }
    }
    
    override init(frame: CGRect) {
        view = T.init()
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        backgroundColor = Color.Base.mainBackground
        
        addSubview(view)
        view.stickToSuperviewEdges([.left, .top])
        
        let const = view.bottom()
        const.priority = UILayoutPriority(999)
        let const2 = view.trailing()
        const2.priority = UILayoutPriority(999)
        
    }
    
}
