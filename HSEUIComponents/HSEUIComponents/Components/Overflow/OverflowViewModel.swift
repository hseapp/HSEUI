import UIKit
import HSEUI

public class OverflowViewModel: CellViewModel {
    
    private let position: Position

    public enum Position: Equatable {
        case center(CGFloat = -UIScreen.main.bounds.height / 15)
        case top(CGFloat = 50)
        case compact(UIEdgeInsets = .init(top: 64, left: 0, bottom: 64, right: 0))
    }

    public init(data: OverflowData, position: Position = .top(), tapCallback: Action?  = nil) {
        self.position = position
        super.init(view: OverflowViewContainer.self) { view in
            view.update(data: data, position: position, tapCallback: tapCallback)
        }
    }
    
    public override func configure(for collectionView: CollectionView) {
        apply(type: OverflowViewContainer.self) { view in
            view.parentHeight = collectionView.safeBounds.height
        }
    }

}

private class OverflowViewContainer: CellView {
    
    var parentHeight: CGFloat = 0 {
        didSet { updatePositionConstraints() }
    }

    private var view: OverflowView = .init()
    
    private var viewConstraints: AnchoredConstraints?
    
    private var position: OverflowViewModel.Position = .center()
    
    override func commonInit() {
        addSubview(view)
        viewConstraints = view.stickToSuperviewEdges(.all)
    }

    func update(data: OverflowData, position: OverflowViewModel.Position, tapCallback: Action?) {
        var dataCopy = data
        dataCopy.addTapCallback(tapCallback, position: 0)

        view.data = data
        self.position = position
        recalculateViewSize()
    }
    
    private func updatePositionConstraints() {
        switch position {
        case .compact(let insets):
            viewConstraints?.updateInsets(insets)
        case .center(let offset):
            let freeSpace: CGFloat = parentHeight - view.frame.height
            if freeSpace < abs(2 * offset) {
                viewConstraints?.updateInsets(.init(top: abs(offset), left: 0, bottom: abs(offset), right: 0))
            } else {
                viewConstraints?.updateInsets(.init(top: freeSpace / 2 + offset, left: 0, bottom: freeSpace / 2 - offset, right: 0))
            }
        case .top(let offset):
            let bottomOffset: CGFloat = max(offset, parentHeight - offset - view.frame.height)
            viewConstraints?.updateInsets(.init(top: offset, left: 0, bottom: bottomOffset, right: 0))
        }
    }
    
    private func recalculateViewSize() {
        let estimatedSize = view.systemLayoutSizeFitting(UIScreen.main.bounds.size, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        view.frame.size = estimatedSize
    }

}

