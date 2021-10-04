//
//  BigTableVC.swift
//  HSEUIExample
//
//  Created by Matvey Kavtorov on 10/4/21.
//

import UIKit
import HSEUI

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
            }, header: HeaderViewModel(text: "HEADER \(index)"), footer: FooterViewModel(text: "footer \(index)"))
        }))
    }
    

}

extension UIColor {
    
    static func randomLight() -> UIColor {
        return UIColor(red: .random(in: 0.5...1), green: .random(in: 0.5...1), blue: .random(in: 0.5...1), alpha: 1)
    }
    
}

class TextViewModel: CellViewModel {
    
    init(text: String, background: UIColor = .randomLight()) {
        super.init(view: UILabel.self, configureView: { label in
            label.text = text
            label.backgroundColor = background
        })
    }
    
}

class HeaderViewModel: CellViewModel {
    
    init(text: String, background: UIColor = .randomLight()) {
        super.init(view: UILabel.self, configureView: { label in
            label.font = label.font.withSize(30)
            label.text = text
            label.backgroundColor = background
        })
    }
    
}

class FooterViewModel: CellViewModel {
    
    init(text: String, background: UIColor = .randomLight()) {
        super.init(view: UILabel.self, configureView: { label in
            label.textAlignment = .right
            label.text = text
            label.backgroundColor = background
        })
    }
    
}
