//
//  NavigationController.swift
//  HSEUIExample
//
//  Created by Matvey Kavtorov on 2/15/22.
//

import Foundation
import UIKit

class NavigationController: UINavigationController {
    
    init(vc: UIViewController) {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        self.viewControllers = [vc]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
