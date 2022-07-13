//
//  PagerViewModel.swift
//  HSEUI
//
//  Created by Matvey Kavtorov on 7/9/21.
//

import Foundation

open class PageViewModel {
    
    public let title: String?
    
    public let viewModel: CollectionViewModelProtocol
    
    public init(title: String?, viewModel: CollectionViewModelProtocol) {
        self.title = title
        self.viewModel = viewModel
    }
    
    func copy() -> PageViewModel {
        PageViewModel(title: title, viewModel: viewModel.copy())
    }
    
}

open class PagerViewModel: CollectionViewModel {
    
    public override func deselectAllCells() {
        pages.forEach {
            $0.viewModel.deselectAllCells()
        }
    }
    
    public let pages: [PageViewModel]
    
    public let header: CollectionViewModelProtocol?
    
    public init(pages: [PageViewModel], header: CollectionViewModelProtocol?) {
        self.pages = pages
        self.header = header
        super.init()
    }
    
    public override func copy() -> CollectionViewModelProtocol {
        PagerViewModel(pages: pages.map({ $0.copy() }), header: header?.copy())
    }
    
}
