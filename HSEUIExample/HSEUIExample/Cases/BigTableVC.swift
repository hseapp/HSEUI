//
//  BigTableVC.swift
//  HSEUIExample
//
//  Created by Matvey Kavtorov on 10/4/21.
//

import UIKit
import HSEUI
import HSEUIComponents

final class BigTableViewController: UIViewController {

    init() {
        super.init(nibName: nil, bundle: nil)
        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        let collectionView = CollectionView(type: .list)
        view.addSubview(collectionView)
        collectionView.stickToSuperviewEdges(.all)
        
        collectionView.reload(with: CollectionViewModel(sections: (0...10).map { index in
            return SectionViewModel(cells: (0...10).map { row in
                return TextViewModel(text: "cell \(row)")
            }, header: TextViewModel(text: "HEADER \(index)"), footer: TextViewModel(text: "footer \(index)"))
        }))
    }
    

}
