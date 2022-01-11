import UIKit
import HSEUI

public class NewDataLoaderViewModel: CellViewModel {

    private var loadCallback: Action?

    private var titleGetter: () -> String

    public init(backgroundColor: UIColor? = Color.Base.mainBackground,
         titleGetter: @escaping () -> String,
         loadCallback: Action?) {
        self.loadCallback = loadCallback
        self.titleGetter = titleGetter
        super.init(view: NewDataLoaderView.self, configureView: { view in
            view.titleLabel.text = titleGetter()
            view.backgroundColor = backgroundColor
        })
    }

    public override func willBeDisplayed(viewModel: CollectionViewModel) {
        mainQueue(delay: 0.2) {
            if self.getCellView()?.isVisibleInSuperView() == true {
                self.loadCallback?()
            }
        }
        apply(type: NewDataLoaderView.self) { [weak self] (view) in
            view.titleLabel.text = titleGetter()
            self?.markDirty()
        }
    }

}

class NewDataLoaderView: CellView {

    fileprivate let titleLabel:  UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = Font.main(weight: .regular).withSize(13)
        label.textColor = Color.Base.secondary
        label.textAlignment = .center
        return label
    }()

    override func commonInit() {
        addSubview(titleLabel)
        titleLabel.stickToSuperviewEdges(.all, insets: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8))
    }

}


extension UIView {
    
    func isVisibleInSuperView() -> Bool {
        if let scrollView = superview as? UIScrollView {
            if frame.origin.y > scrollView.bounds.height + scrollView.contentOffset.y - 8 { return false }
            if frame.origin.x > scrollView.bounds.width + scrollView.contentOffset.x - 8 { return false }
            return scrollView.isVisibleInSuperView()
        } else if let superview = superview {
            if frame.origin.y > superview.bounds.height - 8 { return false }
            if frame.origin.x > superview.bounds.width - 8 { return false }
            return superview.isVisibleInSuperView()
        } else {
            return true
        }
    }
    
}
