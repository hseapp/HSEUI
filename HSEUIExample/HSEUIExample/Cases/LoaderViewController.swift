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
        SkeletonManager.isEnabled = true
        super.init(features: [.refresh, .skeleton])
    }
    
    override func fetchData() {
        mainQueue(delay: 2) {
            self.loader.getState = { .success }
        }
        mainQueue(delay: 2) {
            self.updateCollection()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func collectionViewModel() -> CollectionViewModelProtocol {
        return CollectionViewModel(cells: [
            TextViewModel(text: "loaded!"),
            TextViewModel(text: "loaded!"),
            TextViewModel(text: "loaded!"),
            TextViewModel(text: "loaded!"),
            TextViewModel(text: "loaded!"),
            TextViewModel(text: "loaded!"),
            TextViewModel(text: "loaded!"),
            TextViewModel(text: "loaded!"),
            TextViewModel(text: "loaded!"),
            TextViewModel(text: "loaded!"),
            TextViewModel(text: "loaded!"),
            TextViewModel(text: "loaded!"),
            TextViewModel(text: "loaded!"),
        ])
    }
    
}
