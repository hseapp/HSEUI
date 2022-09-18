import UIKit

public class FooterViewModel: CellViewModel {
    
    let height: CGFloat
    
    public init(height: CGFloat = 12) {
        self.height = height
        super.init(view: CellView.self, configureView: { view in
            view.heightConstant = height
            view.backgroundColor = Color.Collection.table
        })
    }

    public override func preferredWidth(for parentWidth: CGFloat) -> CGFloat? {
        return parentWidth
    }
    
    public override func preferredHeight(for parentHeight: CGFloat) -> CGFloat? {
        return height
    }
    
}
