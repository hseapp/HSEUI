//
//  CellViewConfiguratorImpl.swift
//  HSEUI
//
//  Created by Mikhail on 09.03.2021.
//

import UIKit

public class CellViewConfigurator<T: UIView>: CellViewConfiguratorProtocol {
    
    public var configureView: ((T) -> Void)?
    
    public var tapCallback: Action?
    
    public var useChevron: Bool?
    
    public var isSelected: Bool = false
    
    public static func builder() -> Builder {
        Builder()
    }
    
    public class Builder {
        
        private var object: CellViewConfigurator<T> = .init()
        
        public func setConfigureView(_ value: ((T) -> Void)?) -> Builder {
            object.configureView = value
            return self
        }
        
        public func setTapCallback(_ value: Action?) -> Builder {
            object.tapCallback = value
            return self
        }
        
        public func setUseChevron(_ value: Bool) -> Builder {
            object.useChevron = value
            return self
        }
        
        public func setSelected(_ value: Bool) -> Builder {
            object.isSelected = value
            return self
        }
        
        public func build() -> CellViewConfigurator<T> {
            return object
        }
    
    }
    
}
