//
//  WebViewModel.swift
//  HSEUI
//
//  Created by Mikhail on 06.07.2021.
//

import WebKit

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
