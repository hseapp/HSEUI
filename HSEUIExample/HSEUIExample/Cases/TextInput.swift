//
//  TextInput.swift
//  HSEUIExample
//
//  Created by Matvey Kavtorov on 9/30/21.
//

import HSEUI
import UIKit

class TIViewController: UIViewController {

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
        
        collectionView.reload(with: CollectionViewModel(cells: [
            OptionViewModel(text: "TEST 1"),
            OptionViewModel(text: "TEST 2"),
            OptionViewModel(text: "TEST 3"),
            OptionViewModel(text: "TEST 4"),
            OptionViewModel(text: "TEST 5"),
            OptionViewModel(text: "TEST 6"),
            OptionViewModel(text: "TEST 6"),
            OptionViewModel(text: "TEST 6"),
            OptionViewModel(text: "TEST 6"),
            TextInputViewModel(),
            OptionViewModel(text: "TEST 2"),
            OptionViewModel(text: "TEST 3"),
            OptionViewModel(text: "TEST 4"),
            OptionViewModel(text: "TEST 5"),
            OptionViewModel(text: "TEST 6"),
            OptionViewModel(text: "TEST 6"),
            OptionViewModel(text: "TEST 6"),
            OptionViewModel(text: "TEST 6"),
            OptionViewModel(text: "TEST 6"),
            OptionViewModel(text: "TEST 6"),
            OptionViewModel(text: "TEST 6"),
            OptionViewModel(text: "TEST 6"),
            OptionViewModel(text: "TEST 6"),
            OptionViewModel(text: "TEST 6"),
            OptionViewModel(text: "TEST 6"),
            OptionViewModel(text: "TEST 6"),
            OptionViewModel(text: "TEST 6"),
            OptionViewModel(text: "TEST 6"),
        ]))
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        additionalSafeAreaInsets.top = withTopView ? topView.bounds.height : 0
        additionalSafeAreaInsets.bottom = 68
    }
    
}



public class TextInputViewModel: CellViewModel {
    
    private var preferredHeight: CGFloat

    public init(
        value: String? = nil,
        placeholder: String? = nil,
        textChanged: ((String?) -> Void)? = nil,
        maxSymbols: Int? = nil,
        keyboardType: UIKeyboardType = .default,
        textContentType: UITextContentType? = nil,
        preferredHeight: CGFloat = 96
    ) {
        var currentValue = value
        self.preferredHeight = preferredHeight
        super.init(view: TextInputView.self)
        let configurator = CellViewConfigurator<TextInputView>.builder()
            .setConfigureView({ [weak self] (view) in
                view.textView.text = currentValue
                view.textView.placeholder = placeholder ?? ""
                view.textChanged = { newText in
                    currentValue = newText
                    textChanged?(newText)
                }
                view.textView.keyboardType = keyboardType
                view.textView.textContentType = textContentType
                view.maxSymbols = maxSymbols
                view.willBeginEditing = {
                    self?.willBeginEditing()
                }
            })
            .build()
        updateConfigurator(configurator)
    }

    private func willBeginEditing() {
        guard let collection = findCollectionView() else { return }
        collection.handleFirstResponder(for: self)
    }

    private func findCollectionView() -> CollectionView? {
        var v = self.getCellView()
        while true {
            if v == nil { return nil }
            if let cv = v as? CollectionView { return cv }
            v = v?.superview
        }
    }
    
    public override func preferredHeight(for parentHeight: CGFloat) -> CGFloat? {
        return preferredHeight
    }

}

class TextInputView: CellView {

    var maxSymbols: Int? {
        didSet {
            updateSymbolsView()
        }
    }

    var textChanged: ((String?) -> Void)?
    var willBeginEditing: Action?

    lazy var textView: PlaceholderTextView = {
        let tv = PlaceholderTextView()
        tv.font = Font.main(weight: .regular).withSize(16)
        tv.textColor = Color.Base.label
        tv.backgroundColor = Color.Base.grayBackground
        tv.layer.cornerRadius = 8
        tv.delegate = self
        return tv
    }()

    private lazy var symbolsLabel: UILabel = {
        let label = UILabel()
        label.font = Font.main(weight: .regular).withSize(13)
        return label
    }()

    @objc private func textChangedSelector() {
        updateSymbolsLabelText()
        textChanged?(textView.text)
    }

    override func commonInit() {
        addSubview(textView)
        addSubview(symbolsLabel)
        textView.stickToSuperviewEdges([.top, .left, .right], insets: UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12))

        symbolsLabel.trailing(12)
        symbolsLabel.top(4, to: textView)
        symbolsLabel.bottom(4)
        labelHeightConstraint = symbolsLabel.height(0)
        updateSymbolsView()
    }

    private var labelHeightConstraint: NSLayoutConstraint?
    private func updateSymbolsView() {
        if maxSymbols != nil {
            labelHeightConstraint?.constant = 16
            symbolsLabel.isHidden = false
            symbolsLabel.text = ""
        } else {
            symbolsLabel.isHidden = true
            labelHeightConstraint?.constant = 0
        }
        updateSymbolsLabelText()
    }
    private func updateSymbolsLabelText() {
        if let maxSymbols = maxSymbols {
            let symbols = textView.text?.count ?? 0
            symbolsLabel.text = "\(symbols)/\(maxSymbols)"
            if symbols > maxSymbols {
                symbolsLabel.textColor = Color.Base.red
            } else {
                symbolsLabel.textColor = Color.Base.label
            }
        } else {
            symbolsLabel.text = nil
        }
    }

}

extension TextInputView: UITextViewDelegate {

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        willBeginEditing?()
        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        self.textView.textViewDidChange(textView)
        textChangedSelector()
    }
}

public class PlaceholderTextView: UIView {
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textColor = Color.Base.placeholder
        label.numberOfLines = 0
        return label
    }()
    
    private let textView: UITextView = {
        let view = UITextView()
        view.backgroundColor = .clear
        view.showsVerticalScrollIndicator = false
        return view
    }()
    
    public var placeholder: String = "" {
        didSet {
            placeholderLabel.text = placeholder
            placeholderLabel.isHidden = !textView.text.isEmpty
        }
    }
    
    public var font: UIFont? {
        didSet {
            placeholderLabel.font = font
            textView.font = font
        }
    }
    
    public var textColor: UIColor? {
        didSet {
            textView.textColor = textColor
        }
    }
    
    public var delegate: UITextViewDelegate? {
        didSet {
            textView.delegate = delegate
        }
    }
    
    public var keyboardType: UIKeyboardType = .default {
        didSet {
            textView.keyboardType = keyboardType
        }
    }
    
    public var textContentType: UITextContentType?{
        didSet {
            textView.textContentType = textContentType
        }
    }
    
    public var padding: UIEdgeInsets = .init(top: 12, left: 12, bottom: 12, right: 12)
    
    public var text: String? {
        set {
            textView.text = newValue
        }
        get {
            textView.text
        }
    }
    
    init() {
        super.init(frame: .zero)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        textView.textContainerInset = padding
        textView.textContainer.lineFragmentPadding = 0
        
        addSubview(placeholderLabel)
        placeholderLabel.stickToSuperviewEdges([.left, .right, .top], insets: padding)
        placeholderLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -padding.bottom).isActive = true
        
        addSubview(textView)
        textView.stickToSuperviewEdges(.all)
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
}
