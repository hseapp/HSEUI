import UIKit
import HSEUI

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
