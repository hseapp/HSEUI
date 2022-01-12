import UIKit
import HSEUI

open class BaseEntityHeaderView<T>: CellView {

    public var data: T? {
        didSet { update() }
    }

    public let mainTitle: UILabel = {
        let label = UILabel()
        label.font = Font.main(weight: .semibold).withSize(17)
        label.numberOfLines = 2
        return label
    }()

    public let upperTitle: UILabel = {
        let label = UILabel()
        label.font = Font.main(weight: .semibold).withSize(11)
        label.textColor = Color.Base.brandTint
        return label
    }()

    public let subtitle: UILabel = {
        let label = UILabel()
        label.font = Font.main(weight: .regular).withSize(14)
        label.textColor = Color.Base.secondary
        label.numberOfLines = 0
        return label
    }()

    open override func commonInit() {
        addSubview(upperTitle)
        upperTitle.stickToSuperviewEdges([.left, .top, .right], insets: .init(top: 4, left: 16, bottom: 0, right: 16))

        addSubview(mainTitle)
        mainTitle.stickToSuperviewEdges([.left, .right], insets: .init(top: 0, left: 16, bottom: 0, right: 16))
        mainTitle.top(4, to: upperTitle)

        addSubview(subtitle)
        subtitle.top(6, to: mainTitle)
        subtitle.stickToSuperviewEdges([.left, .bottom, .right], insets: .init(top: 0, left: 16, bottom: 4, right: 16))
    }

    open func update() {
        assertionFailure("Should be overridden")
    }

}
