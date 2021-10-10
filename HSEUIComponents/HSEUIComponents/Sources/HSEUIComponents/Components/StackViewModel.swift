import UIKit
import HSEUI

open class StackViewModel: CellViewModel {

    public convenience init(cells: [CellViewModelProtocol],
         axis: NSLayoutConstraint.Axis = .horizontal,
         spacing: CGFloat = 0,
         alignment: UIStackView.Alignment = .fill,
         distribution: UIStackView.Distribution = .fill,
         backgroundColor: UIColor = Color.Base.mainBackground,
         insets: UIEdgeInsets? = nil,
         deleteAction: Action? = nil) {
        self.init(viewModel: CollectionViewModel(cells: cells), axis: axis, spacing: spacing, alignment: alignment, distribution: distribution, backgroundColor: backgroundColor, insets: insets, deleteAction: deleteAction)
    }
    
    public init(viewModel: CollectionViewModel,
         axis: NSLayoutConstraint.Axis = .horizontal,
         spacing: CGFloat = 0,
         alignment: UIStackView.Alignment = .fill,
         distribution: UIStackView.Distribution = .fill,
         backgroundColor: UIColor = Color.Base.mainBackground,
         insets: UIEdgeInsets? = nil,
         deleteAction: Action? = nil) {
        super.init(view: StackViewContainer.self, configureView: { container in
            container.update(viewModel: viewModel, axis: axis, spacing: spacing, alignment: alignment, distribution: distribution, insets: insets, backgroundColor: backgroundColor)
        })
        self.deleteAction = deleteAction
    }

}

open class StackViewContainer: CellView {

    public let stack = UIStackView()

    var insets: UIEdgeInsets = .zero {
        didSet {
            stackConstraints?.updateInsets(insets)
        }
    }

    private var stackConstraints: AnchoredConstraints?

    open override func commonInit() {
        addSubview(stack)
        stackConstraints = stack.stickToSuperviewEdges(.all, insets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
    }
    
    public func update(viewModel: CollectionViewModelProtocol,
                       axis: NSLayoutConstraint.Axis = .horizontal,
                       spacing: CGFloat = 0,
                       alignment: UIStackView.Alignment = .fill,
                       distribution: UIStackView.Distribution = .fill,
                       insets: UIEdgeInsets? = nil,
                       backgroundColor: UIColor = Color.Base.mainBackground) {
        self.backgroundColor = backgroundColor
        let cells = viewModel.sections.reduce([], { return $0 + $1.cells })
        
        stack.axis = axis
        stack.spacing = spacing
        stack.alignment = alignment
        stack.distribution = distribution
        
        while stack.arrangedSubviews.count > cells.count {
            let v = stack.arrangedSubviews[stack.arrangedSubviews.count - 1]
            stack.removeArrangedSubview(v)
            v.removeFromSuperview()
        }
        for i in 0..<stack.arrangedSubviews.count {
            if !cells[i].updateView(view: stack.arrangedSubviews[i]) {
                let v = stack.arrangedSubviews[i]
                stack.removeArrangedSubview(v)
                v.removeFromSuperview()
                stack.insertArrangedSubview(cells[i].initView(), at: i)
            }
        }
        for i in stack.arrangedSubviews.count..<cells.count {
            stack.addArrangedSubview(cells[i].initView())
        }
        self.insets = insets ?? UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }

}
