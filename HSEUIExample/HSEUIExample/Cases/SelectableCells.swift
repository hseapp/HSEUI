//
//  SelectableCells.swift
//  HSEUIExample
//
//  Created by Matvey Kavtorov on 10/6/21.
//

import UIKit
import HSEUI

final class SelectableCellsViewController: UIViewController {

    init() {
        super.init(nibName: nil, bundle: nil)
        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let collectionView = CollectionView(type: .list)
    private var viewModel = CollectionViewModel()
    
    private func commonInit() {
        view.addSubview(collectionView)
        collectionView.stickToSuperviewEdges(.all)
        
        let bottomButton = BottomButtonView()
        view.addSubview(bottomButton)
        bottomButton.stickToSuperviewSafeEdges([.left, .right])
        bottomButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        bottomButton.title = "Select"
        additionalSafeAreaInsets.bottom = 68
        bottomButton.action = { [weak self] in
            self?.selectCells()
        }
        viewModel = CollectionViewModel(cells: [
            CustomSelectableCell(),
            CustomSelectableCell(),
            CustomSelectableCell()
        ], selectionStyle: .multiple)
        collectionView.reload(with: viewModel)
    }
    
    private func selectCells() {
        if let firstCell = viewModel.sections.first?.cells.first as? CustomSelectableCell {
            firstCell.highlight()
        }
        if let lastCell = viewModel.sections.first?.cells.last as? CustomSelectableCell {
            lastCell.highlight()
        }
    }
    

}

class CustomSelectableCell: CellViewModel {
    
    init() {
        super.init(view: CustomSelectableView.self)
    }
    
    func highlight() {
        isSelected = true
        mainQueue(delay: 1) {
            self.isSelected = false
        }
    }
    
}

class CustomSelectableView: CellView {
    
    override func commonInit() {
        super.commonInit()
        height(44)
        backgroundColor = .blue
    }
    
    override func setSelectedUI(selected: Bool) {
        backgroundColor = selected ? .red : .blue
    }
    
}
