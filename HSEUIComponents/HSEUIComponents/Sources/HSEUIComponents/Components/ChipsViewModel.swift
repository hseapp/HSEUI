import UIKit
import HSEUI

public class ChipsViewModel: CellViewModel {
    
    public init(
        header: String? = nil,
        insets: UIEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16),
        spacing: CGFloat = 8,
        viewModel: CollectionViewModel
    ) {
        super.init(view: ChipsView.self, configureView: { view in
            view.update(viewModel: viewModel, headerText: header, insets: insets, spacing: spacing)
        })
    }

}

class ChipsView: CellView {
    
    private var headerConstraints: AnchoredConstraints?
    
    public let header: UILabel = {
        let label = UILabel()
        label.font = Font.main(weight: .regular).withSize(14)
        label.textColor = Color.Base.secondary
        label.numberOfLines = 0
        return label
    }()

    private let collectionView = CollectionView(type: .chips)

    override func commonInit() {
        addSubview(header)
        headerConstraints = header.stickToSuperviewEdges([.left, .right, .top], insets: .init(top: 12, left: 16, bottom: 0, right: 16))
        headerConstraints?.height = header.height(0, priority: .required)
        
        addSubview(collectionView)
        collectionView.stickToSuperviewEdges([.left, .right, .bottom], insets: .init(top: 0, left: 0, bottom: 8, right: 0))
        collectionView.top(4, to: header)
    }
    
    func update(viewModel: CollectionViewModel, headerText: String?, insets: UIEdgeInsets, spacing: CGFloat) {
        collectionView.reload(with: viewModel)
        collectionView.spacing = spacing
        collectionView.contentInset = insets
        updateHeaderView(text: headerText)
    }
    
    private func updateHeaderView(text: String?) {
        if let text = text {
            header.text = text
            headerConstraints?.height?.isActive = false
            headerConstraints?.top?.constant = 12
        } else {
            headerConstraints?.height?.isActive = true
            headerConstraints?.top?.constant = 6
        }
    }

}
