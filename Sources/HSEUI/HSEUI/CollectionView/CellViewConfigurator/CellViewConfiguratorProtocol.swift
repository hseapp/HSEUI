//
//  CellViewConfigurator.swift
//  HSEUI
//
//  Created by Mikhail on 10.03.2021.
//

import UIKit

public protocol CellViewConfiguratorProtocol {
    associatedtype T: UIView
    var configureView: ((T) -> Void)? { set get }
    var tapCallback: Action? { set get }
    var useChevron: Bool? { set get }
}
