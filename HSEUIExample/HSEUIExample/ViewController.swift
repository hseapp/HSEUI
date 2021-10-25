//
//  ViewController.swift
//  HSEUIExample
//
//  Created by Matvey Kavtorov on 9/27/21.
//

import UIKit
import HSEUI
import HSEUIComponents

class ViewController: UIViewController {
    
    let chipsCollectionView = CollectionView(type: .chips)
    
    let listCollectionView = CollectionView(type: .list)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.addSubview(chipsCollectionView)
        view.addSubview(listCollectionView)
        listCollectionView.stickToSuperviewEdges([.left, .right, .bottom])
        listCollectionView.top(0, to: chipsCollectionView)
        chipsCollectionView.stickToSuperviewSafeEdges([.left, .right, .top], insets: UIEdgeInsets(top: 90, left: 0, bottom: 0, right: 0))
        chipsCollectionView.backgroundColor = .red
        chipsCollectionView.reload(with: CollectionViewModel(cells: [
            FilterViewModel(text: "TEST", value: 0),
            FilterViewModel(text: "MULTILINE\nMULTILINE", value: 0),
            FilterViewModel(text: "LONG LONG LONG LONG LONG LONG LONG LONG LONG LONG LONG LONG LONG LONG LONG", value: 0),
            FilterViewModel(text: "Text input", value: 0, didValueChange: { [weak self] in
                self?.present(TIViewController(), animated: true, completion: nil)
            }),
            FilterViewModel(text: "Text input BS", value: 0, didValueChange: { [weak self] in
                self?.showControllerAsBottomsheet(TIViewController())
            }),
            FilterViewModel(text: "small BS", value: 0, didValueChange: { [weak self] in
                self?.showControllerAsBottomsheet(OptionPickerViewController())
            }),
            
            FilterViewModel(text: "table with headers", value: 0, didValueChange: { [weak self] in
                self?.present(BigTableViewController(), animated: true, completion: nil)
            }),
            
            FilterViewModel(text: "Selectable cells", value: 0, didValueChange: { [weak self] in
                self?.present(SelectableCellsViewController(), animated: true, completion: nil)
            }),
            
            FilterViewModel(text: "Lists collection BS", value: 0, didValueChange: { [weak self] in
                self?.showControllerAsBottomsheet(ListsCollectionBSViewController())
            }),
        ]))
        
        listCollectionView.reload(with: CollectionViewModel(cells: [
            TextViewModel(text: "Loader VC", tapCallback: { [weak self] in
                self?.present(LoaderViewController(), animated: true, completion: nil)
            })
        ]))
    }

}

final class FilterViewModel<T>: CellViewModel {

    private(set) var value: T

    init(text: String, value: T, cornerRadius: CGFloat = 16, didValueChange: (()->())? = nil) {
        self.value = value
        super.init(view: FilterView.self, configureView: { view in
            view.label.text = text
            view.layer.cornerRadius = cornerRadius
        }, tapCallback: {
            didValueChange?()
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }, useChevron: false)
    }
    
}

class FilterView: CellView {

    private var isSelected: Bool = false

    let label: UILabel = {
        let label = UILabel()
        label.font = Font.main(weight: .regular).withSize(14)
        label.allowsDefaultTighteningForTruncation = false
        label.numberOfLines = 0
        return label
    }()

    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    override func setUpView() {
        layer.borderWidth = 1
    }

    override func commonInit() {
        addSubview(label)
        label.stickToSuperviewEdges(.all, insets: .init(top: 8, left: 12, bottom: 8, right: 12))
        label.centerVertically()
        label.textAlignment = .center

        setSelectedUI(selected: false)
    }

    override func setSelectedUI(selected: Bool) {
        isSelected = selected
        backgroundColor = selected ? Color.Base.brandTint : Color.Base.mainBackground
        layer.borderColor = (selected ? Color.Base.brandTint : UIColor.gray).cgColor
        label.textColor = selected ? Color.Base.white : Color.Base.label
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        layer.borderColor = (isSelected ? Color.Base.brandTint : UIColor.gray).cgColor
    }

}

