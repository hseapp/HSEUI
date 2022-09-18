//
//  UIView+SafeBounds.swift
//  HSEUI
//
//  Created by Mikhail on 16.07.2021.
//

import UIKit

public extension UIView {
    
    @objc var safeBounds: CGRect {
        return CGRect(x: safeAreaInsets.left + bounds.origin.x,
                      y: safeAreaInsets.top + bounds.origin.y,
                      width: bounds.width - safeAreaInsets.left - safeAreaInsets.right,
                      height: bounds.height - safeAreaInsets.top - safeAreaInsets.bottom)
    }
    
}
