//
//  HSEUISettings.swift
//  HSEUI
//
//  Created by Matvey Kavtorov on 3/18/21.
//

import UIKit

public class HSEUISettings {
    
    public static let main = HSEUISettings()
    
    public var fontCollection: FontCollection = DefaultFontCollection()
    
    var refreshControlViewClass: RefreshControlViewProtocol.Type = DefaultRefreshControlView.self
    public func setRefreshControlClass<T>(_ type: T.Type) where T: RefreshControlViewProtocol {
        refreshControlViewClass = type
    }
    
    private init() { }
    
}
