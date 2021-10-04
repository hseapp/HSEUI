//
//  OptionPickerViewController.swift
//  HSEUIExample
//
//  Created by Matvey Kavtorov on 9/30/21.
//

import UIKit
import HSEUI

final class OptionPickerViewController: UIViewController {

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
        
        let bottomButton = BottomButtonView()
        view.addSubview(bottomButton)
        bottomButton.stickToSuperviewSafeEdges([.left, .right])
        bottomButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        bottomButton.title = "Button"
//        additionalSafeAreaInsets.bottom = 68
        
        collectionView.reload(with: CollectionViewModel(cells: [
            OptionViewModel(text: "TEST 1"),
            OptionViewModel(text: "TEST 2")
        ]))
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        additionalSafeAreaInsets.top = withTopView ? topView.bounds.height : 0
        additionalSafeAreaInsets.bottom = 68
    }
    

}

final class OptionViewModel: CellViewModel {

    init(text: String, description: String? = nil) {
        super.init(view: OptionView.self, configureView: { view in
            view.update(text: text, description: description)
        }, tapCallback: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }, useChevron: false)
    }
}

final class OptionView: CellView {

    private let label: UILabel = {
        let label = UILabel()
        label.font = Font.main
        label.allowsDefaultTighteningForTruncation = false
        label.numberOfLines = 0
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = Font.main.withSize(13)
        label.textColor = Color.Base.secondary
        label.numberOfLines = 0
        return label
    }()
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = Color.Base.brandTint
        iv.image = sfSymbol("tick")?.withTintColor(Color.Base.brandTint, renderingMode: .alwaysOriginal)
        return iv
    }()
    
    private var labelBottom: NSLayoutConstraint?
    
    private var descriptionLabelBottom: NSLayoutConstraint?

    override func setUpView() {
        setSelectedUI(selected: false)
    }

    override func commonInit() {
        addSubview(imageView)
        imageView.trailing(20)
        imageView.exactSize(.init(width: 24, height: 24))
        imageView.centerVertically()

        addSubview(label)
        labelBottom = label.stickToSuperviewEdges([.left, .top, .bottom], insets: .init(top: 12, left: 16, bottom: 14, right: 0))?.bottom
        label.trailing(8, to: imageView)
        
        addSubview(descriptionLabel)
        descriptionLabelBottom = descriptionLabel.stickToSuperviewEdges([.left, .bottom], insets: .init(top: 0, left: 16, bottom: 14, right: 0))?.bottom
        descriptionLabel.top(2, to: label)
        descriptionLabel.trailing(8, to: imageView)
        descriptionLabelBottom?.isActive = false
        
        heightAnchor.constraint(greaterThanOrEqualToConstant: 48).isActive = true
    }
    
    func update(text: String, description: String?) {
        label.text = text
        descriptionLabel.text = description
        if descriptionLabel.text == nil {
            descriptionLabel.isHidden = true
            descriptionLabelBottom?.isActive = false
            labelBottom?.isActive = true
        } else {
            descriptionLabel.isHidden = false
            labelBottom?.isActive = false
            descriptionLabelBottom?.isActive = true
        }
    }

    override func setSelectedUI(selected: Bool) {
        imageView.isHidden = !selected
    }
    
    override func touchBegan() {
        backgroundColor = Color.Base.selection
        if imageView.isHidden { imageView.alpha = 0 }
    }
    
    override func touchEnded() {
        backgroundColor = Color.Base.mainBackground
        imageView.alpha = 1
    }

}

open class BottomButtonView: UIView {

    public enum State {
        case enabled, disabled, unpainted
    }

    public var state: State = .enabled {
        didSet {
            if state != oldValue { updateUI() }
        }
    }

    private let button: UIButton
    
    public var isSeparatorHidden: Bool {
        get {
            return separator.isHidden
        }
        set {
            separator.isHidden = newValue
        }
    }

    let separator: UIView = {
        let view = UIView()
        view.backgroundColor = Color.Base.separator
        view.height(0.5)
        return view
    }()
    
    let cover = UIVisualEffectView(effect: UIBlurEffect(style: .defaultHSEUI))

    public var title: String = "" {
        didSet {
            button.setTitle(title, for: .normal)
        }
    }

    public var action: Action?

    public init() {
        self.button = UIButton()
        self.button.backgroundColor = Color.Base.brandTint
        super.init(frame: .zero)
        setUpView()
        commonInit()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView() {
//        backgroundColor = Color.Base.mainBackground
        backgroundColor = .clear
        button.titleLabel?.font = Font.main(weight: .medium)
        button.layer.borderColor = Color.Base.brandTint.cgColor
    }

    private func commonInit() {
        addSubview(cover)
        cover.stickToSuperviewEdges(.all)
        
        addSubview(button)
        button.stickToSuperviewSafeEdges(.all, insets: .init(top: 12, left: 12, bottom: 12, right: 12))
        button.height(45)
        
        addSubview(separator)
        separator.stickToSuperviewEdges([.top, .left, .right])
        
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    @objc private func buttonTapped() {
        action?()
    }

    private func updateUI() {
        button.isEnabled = state != .disabled
        switch state {
        case .enabled:
            button.backgroundColor = Color.Base.brandTint
            button.setTitleColor(Color.Base.white, for: .normal)
            button.layer.borderWidth = 0
        case .disabled:
            button.backgroundColor = Color.Base.brandTint.withAlphaComponent(0.5)
            button.setTitleColor(Color.Base.white.withAlphaComponent(0.7), for: .normal)
            button.layer.borderWidth = 0
        case .unpainted:
            button.backgroundColor = Color.Base.mainBackground
            button.setTitleColor(Color.Base.brandTint, for: .normal)
            button.layer.borderWidth = 1
        }
    }

}
