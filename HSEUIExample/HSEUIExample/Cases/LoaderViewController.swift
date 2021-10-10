//
//  LoaderViewController.swift
//  HSEUIExample
//
//  Created by Matvey Kavtorov on 10/10/21.
//

import HSEUI
import HSEUIComponents

class LoaderViewController: CollectionViewController {
    
    init() {
        super.init(features: [.refresh])
    }
    
    override func fetchData() {
        mainQueue(delay: 5) {
            self.updateCollection()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func collectionViewModel() -> CollectionViewModelProtocol {
        return CollectionViewModel(cells: [
            TextViewModel(text: "loaded!")
        ])
    }
    
}
