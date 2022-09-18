import UIKit

public class SeparatorViewModel: CellViewModel {

    public init(insets: UIEdgeInsets = .init(top: 0, left: 12, bottom: 0, right: 12)) {
        super.init(view: SeparatorView.self, configureView: { separatorView in
            separatorView.insets = insets
        })
    }

    public override func preferredWidth(for parentWidth: CGFloat) -> CGFloat? {
        return parentWidth
    }
    
    public override func preferredHeight(for parentHeight: CGFloat) -> CGFloat? {
        return 1
    }
    
}

public class SeparatorView: CellView {

    public var insets: UIEdgeInsets = .zero {
        didSet {
            separatorConstraints?.updateInsets(insets)
        }
    }

    private var separatorConstraints: AnchoredConstraints?

    private let separatorView: UIView = {
        let separatorView = UIView()
        separatorView.backgroundColor = Color.Base.separator
        separatorView.isUserInteractionEnabled = false
        return separatorView
    }()

    public override func commonInit() {
        addSubview(separatorView)
        separatorConstraints = separatorView.stickToSuperviewEdges(.all)
        separatorConstraints?.height = separatorView.height(0.5)
        widthConstant = 44
    }

}
