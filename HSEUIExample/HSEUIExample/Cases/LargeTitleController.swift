//
//  LargeTitleController.swift
//  HSEUIExample
//
//  Created by Matvey Kavtorov on 2/15/22.
//

import UIKit
import HSEUI

class LargeTitleController: UIViewController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
        title = "Large title"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let collectionView = CollectionView(type: .list)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(collectionView)
        collectionView.stickToSuperviewEdges(.all)
        collectionView.setUpRefresher { [weak self] in
            print("refreshing!")
            mainQueue(delay: 3) {
                self?.reload()
            }
        }
        self.navigationController?.navigationBar.prefersLargeTitles = true
        reload()
    }
    
    private func reload() {
        collectionView.reload(with: collectionViewModel())
    }
    
    func collectionViewModel() -> CollectionViewModelProtocol {
        return CollectionViewModel(cells: [])
    }
    
}
