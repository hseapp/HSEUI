import UIKit
import HSEUI

final public class ImageViewModel: CellViewModel {
    
    public enum Layout {
        case `default`
        case addingParentWidth(CGFloat)
        case center
    }
    
    private let layout: Layout
    
    public let source: ImageSource
    
    public init(source: ImageSource, layout: Layout = .default, tapCallback: Action? = nil) {
        self.source = source
        self.layout = layout
        switch layout {
        case .default:
            super.init(view: ImageViewCompact.self, configureView: {
                $0.imageView.setItem(source.imageItem)
            }, tapCallback: tapCallback)
        case .addingParentWidth:
            super.init(view: ImageViewContainer.self, configureView: {
                $0.imageView.setItem(source.imageItem)
            }, tapCallback: tapCallback)
        case .center:
            super.init(view: ImageViewCentered.self, configureView: {
                $0.imageView.setItem(source.imageItem)
            }, tapCallback: tapCallback)
        }
    }
    
    public override func preferredWidth(for parentWidth: CGFloat) -> CGFloat? {
        switch layout {
        case .default:
            return parentWidth
        case .addingParentWidth(let offset):
            return parentWidth + offset
        case .center:
            return parentWidth
        }
    }
}

private class ImageViewContainer: CellView {
    
    fileprivate let imageView: ImageView = {
        let iv = ImageView()
        iv.layer.cornerRadius = 8
        return iv
    }()
    
    override func commonInit() {
        addSubview(imageView)
        imageView.stickToSuperviewEdges(.all, insets: .init(top: 0, left: 0, bottom: 0, right: 0))
        imageView.height(134)
    }
    
}

private class ImageViewCompact: ImageViewContainer {
    
    override func commonInit() {
        addSubview(imageView)
        imageView.stickToSuperviewEdges(.all, insets: .init(top: 12, left: 16, bottom: 12, right: 16))
        imageView.height(134)
    }
    
}

private class ImageViewCentered: ImageViewContainer {
    
    override func commonInit() {
        let container = UIView()
        addSubview(container)
        container.addSubview(imageView)
        imageView.placeInCenter()
        container.stickToSuperviewEdges([.all], insets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
    }
    
}
