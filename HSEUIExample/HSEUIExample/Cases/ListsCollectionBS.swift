//
//  ListsCollectionBS.swift
//  HSEUIExample
//
//  Created by Matvey Kavtorov on 10/25/21.
//

import HSEUI
import HSEUIComponents
import UIKit

class ListsCollectionBSViewController: CollectionViewController {
    
    init() {
        super.init(features: [.bottomButton, .pageSelector], selectorTitles: ["A", "B"])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        (collectionView as? PagerPresentable)?.changePage(newIndex: 0, animated: false)
    }
    
    override func collectModels() -> [CollectionViewModelProtocol] {
        var result: [CollectionViewModel] = []
        for text in ["A", "B"] {
            var cells: [CellViewModel] = []
//            if libraries.count < 2 {
//                cells.append(HeaderViewModel(text: text, style: .primary))
//            }
            cells.append(ImageWithTextViewModel(image: sfSymbol("map.fill")!, text: text, numberOfLines: 0))
            cells.append(ImageWithTextViewModel(image: sfSymbol("map.fill")!, text: text, numberOfLines: 0))
            cells.append(ImageWithTextViewModel(image: sfSymbol("map.fill")!, text: text, numberOfLines: 0))
            cells.append(ImageWithTextViewModel(image: sfSymbol("map.fill")!, text: text, numberOfLines: 0))
            cells.append(ImageWithTextViewModel(image: sfSymbol("map.fill")!, text: text, numberOfLines: 0))
            cells.append(ImageWithTextViewModel(image: sfSymbol("map.fill")!, text: text, numberOfLines: 0))
            cells.append(ImageWithTextViewModel(image: sfSymbol("map.fill")!, text: text, numberOfLines: 0))
            cells.append(ImageWithTextViewModel(image: sfSymbol("map.fill")!, text: text, numberOfLines: 0))
            cells.append(ImageWithTextViewModel(image: sfSymbol("map.fill")!, text: text, numberOfLines: 0))
            cells.append(ImageWithTextViewModel(image: sfSymbol("map.fill")!, text: text, numberOfLines: 0))
            cells.append(ImageWithTextViewModel(image: sfSymbol("map.fill")!, text: text, numberOfLines: 0))
            cells.append(ImageWithTextViewModel(image: sfSymbol("map.fill")!, text: text, numberOfLines: 0))
            
            result.append(CollectionViewModel(cells: cells))
        }
        return result
    }
    
    override func setUpBottomButtonView() {
        bottomButton.action = {
            
        }
        bottomButton.title = "OK"
    }
    
}
