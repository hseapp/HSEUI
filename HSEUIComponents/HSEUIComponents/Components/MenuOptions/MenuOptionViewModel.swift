import UIKit
import HSEUI

public class MenuOptionViewModel: CellViewModel {
    
    public let option: String

    public init(option: String, tapCallback: @escaping Action) {
        self.option = option
        super.init(view: MenuOptionView.self, configureView: {$0.option = option}, tapCallback: tapCallback, useChevron: false)
    }

}

class MenuOptionView: CellView {

    var option: String? {
        didSet { update() }
    }

    private let title: UILabel = {
        let label = UILabel()
        label.font = Font.main(weight: .medium).withSize(16)
        label.textAlignment = .center
        return label
    }()

    override func commonInit() {
        addSubview(title)
        title.stickToSuperviewEdges([.left, .right], insets: .init(top: 0, left: 16, bottom: 0, right: 16))
        title.centerVertically()
        layer.cornerRadius = 16
        height(32)
    }

    private func update() {
        guard let option = option else { return }
        if option.count > 25 {
            self.title.font = Font.main(weight: .medium).withSize(12)
        } else {
            self.title.font = Font.main(weight: .medium).withSize(16)
        }
        self.title.text = option
        title.textColor = isSelected ? Color.Base.brandTint : Color.Base.secondary
    }

    private var isSelected: Bool = false

    override func setSelectedUI(selected: Bool) {
        isSelected = selected
        if selected {
            backgroundColor = Color.Base.brandTint.withAlphaComponent(0.08)
            title.textColor = Color.Base.brandTint
        } else {
            backgroundColor = Color.Base.mainBackground
            title.textColor = Color.Base.secondary
        }
    }

}
