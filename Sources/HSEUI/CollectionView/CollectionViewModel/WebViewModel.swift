//
//  WebViewModel.swift
//  HSEUI
//
//  Created by Mikhail on 06.07.2021.
//

#if !os(watchOS)
import WebKit
#endif

open class WebViewModel: CollectionViewModel {
    
    public var link: String
    
    public init(link: String) {
        self.link = link
        super.init()
    }
    
    public override func copy() -> CollectionViewModelProtocol {
        WebViewModel(link: link)
    }
    
}
