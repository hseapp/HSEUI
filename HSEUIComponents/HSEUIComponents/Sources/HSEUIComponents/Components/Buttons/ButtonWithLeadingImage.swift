import UIKit
import HSEUI

public class BrandButtonWithLeadingImage: BrandButton {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        contentHorizontalAlignment = .leading
        adjustsImageWhenHighlighted = false
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        guard let imageView = imageView, let titleLabel = titleLabel else { return }

        let offset = (bounds.size.width - titleLabel.bounds.size.width) / 2 - 6 - imageView.bounds.size.width

        titleEdgeInsets = .init(top: 0, left: offset, bottom: 0, right: 0)
        imageEdgeInsets = .init(top: 0, left: 6, bottom: 0, right: 0)
    }

}
