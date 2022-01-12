import UIKit
import HSEUI

public class PaddingViewModel: CellViewModel {

    public var padding: CGFloat = 8 {
        didSet {
            if axis == .vertical {
                apply(type: CellView.self) { (view) in
                    view.heightConstant = padding
                }
            } else if axis == .horizontal {
                apply(type: CellView.self) { (view) in
                    view.widthConstant = padding
                }
            }
        }
    }
    
    private let axis: NSLayoutConstraint.Axis?

    public init(padding: CGFloat = 8, axis: NSLayoutConstraint.Axis? = .vertical) {
        self.padding = padding
        self.axis = axis
        super.init(view: CellView.self, configureView: {
            $0.isUserInteractionEnabled = false
            $0.backgroundColor = Color.Base.mainBackground
            if axis == .vertical {
                $0.heightConstant = padding
            } else if axis == .horizontal {
                $0.widthConstant = padding
            }
        })
        voiceOver.accessibilityElementsHidden = true
    }

    public override func preferredWidth(for parentWidth: CGFloat) -> CGFloat? {
        return parentWidth
    }

    public override func preferredHeight(for parentHeight: CGFloat) -> CGFloat? {
        return padding
    }

}
