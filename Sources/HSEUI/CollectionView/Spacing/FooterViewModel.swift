//
//  FooterViewModel.swift
//  HSEAppX
//
//  Created by Mikhail on 13.08.2020.
//  Copyright © 2020 National Research University “Higher School of Economics“. All rights reserved.
//

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
