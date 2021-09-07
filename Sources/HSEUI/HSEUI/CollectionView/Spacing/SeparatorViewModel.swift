//
//  SeparatorViewModel.swift
//  HSEAppX
//
//  Created by Matvey Kavtorov on 8/12/20.
//  Copyright © 2020 National Research University “Higher School of Economics“. All rights reserved.
//

import UIKit

public class SeparatorViewModel: CellViewModel {

    public init(insets: UIEdgeInsets = .init(top: 0, left: 12, bottom: 0, right: 12)) {
        super.init(view: SeparatorView.self, configureView: { separatorView in
            separatorView.insets = insets
        })
        voiceOver.accessibilityElementsHidden = true
    }

    public override func preferredWidth(for parentWidth: CGFloat) -> CGFloat? {
        return parentWidth
    }
    
    public override func preferredHeight(for parentHeight: CGFloat) -> CGFloat? {
        return 1
    }
}

public class SeparatorView: CellView {

    public var insets: UIEdgeInsets = .zero {
        didSet {
            separatorConstraints?.updateInsets(insets)
        }
    }

    private var separatorConstraints: AnchoredConstraints?

    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = Color.Base.separator
        view.isUserInteractionEnabled = false
        return view
    }()

    public override func commonInit() {
        addSubview(separator)
        separatorConstraints = separator.stickToSuperviewEdges(.all)
        separatorConstraints?.height = separator.height(0.5)
        widthConstant = 44
    }

}
