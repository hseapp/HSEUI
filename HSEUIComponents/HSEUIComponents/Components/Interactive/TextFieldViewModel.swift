import UIKit
import HSEUI

public class TextFieldViewModel: CellViewModel {
    
    private var text: String?
    
    public init(
        placeholder: String? = nil,
        value: String? = nil,
        header: String? = nil,
        isEditable: Bool = true,
        textChanged: ((String?) -> Void)? = nil,
        deleteAction: Action? = nil,
        maxSymbols: Int? = nil,
        keyboardType: UIKeyboardType = .default,
        textContentType: UITextContentType? = nil,
        isRequired: Bool = true,
        width: CGFloat? = nil,
        leadingInset: CGFloat = 12,
        infoCallback: Action? = nil,
        tapCallback: Action? = nil
    ) {
        self.text = value
        super.init(view: TextFieldView.self)
        
        let textEdition: (String?) -> Void = { [weak self] newValue in
            self?.text = newValue
            textChanged?(newValue)
        }
        
        let configurator = CellViewConfigurator<TextFieldView>.builder()
            .setConfigureView({ [weak self] (view) in
                view.update(placeholder: placeholder, value: self?.text, header: header, isEditable: isEditable, textChanged: textEdition, deleteAction: deleteAction, maxSymbols: maxSymbols, keyboardType: keyboardType, textContentType: textContentType, isRequired: isRequired, width: width, leadingInset: leadingInset, willBeginEditing: self?.willBeginEditing, infoCallback: infoCallback, tapCallback: tapCallback)
            })
            .setTapCallback(tapCallback)
            .setUseChevron(false)
            .build()
        updateConfigurator(configurator)
        self.deleteAction = deleteAction
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
    
    public override func preferredWidth(for parentWidth: CGFloat) -> CGFloat? {
        return parentWidth
    }
    
}

open class TextFieldView: CellView {
    
    public var maxSymbols: Int?
    
    public var textChanged: ((String?) -> Void)?
    
    private var isRequired: Bool = true
    
    public var willBeginEditing: Action?
    
    private var headerConstraints: AnchoredConstraints?
    
    private var infoImageViewConstraint: AnchoredConstraints?
    
    private var infoCallback: Action?
    
    public let header: UILabel = {
        let label = UILabel()
        label.font = Font.main(weight: .regular).withSize(14)
        label.textColor = Color.Base.secondary
        label.numberOfLines = 0
        return label
    }()
    
    public lazy var textField: UITextField = {
        let tf = UITextField()
        tf.font = Font.main(weight: .regular).withSize(16)
        tf.addTarget(self, action: #selector(textChangedSelector), for: .editingChanged)
        tf.textColor = Color.Base.secondary
        tf.delegate = self
        tf.returnKeyType = .done
        return tf
    }()
    
    private lazy var infoImageView: ImageView = {
        let iv = ImageView()
        iv.placeholder = .symbol("questionmark.circle")
        iv.setTapAction { [weak self] in
            self?.infoCallback?()
        }
        return iv
    }()
    
    public lazy var textFieldContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Color.Base.grayBackground
        view.layer.cornerRadius = 8
        
        view.addSubview(textField)
        textField.stickToSuperviewEdges(.all, insets: .init(top: 12, left: 12, bottom: 12, right: 12))
        
        return view
    }()
    
    private var symbolsLabelConstraints: AnchoredConstraints?
    
    private lazy var symbolsLabel: UILabel = {
        let label = UILabel()
        label.font = Font.main(weight: .regular).withSize(13)
        label.textColor = Color.Base.secondary
        label.textAlignment = .right
        return label
    }()
    
    @objc open func textChangedSelector() {
        updateSymbolsLabelText()
        textChanged?(textField.text)
    }
    
    private var textFieldContainerLeading: NSLayoutConstraint?
    
    open override func commonInit() {
        addSubview(header)
        headerConstraints = header.stickToSuperviewEdges([.left, .right, .top], insets: .init(top: 14, left: 12, bottom: 0, right: 12))
        headerConstraints?.height = header.height(0, priority: .required)
        
        addSubview(textFieldContainer)
        textFieldContainer.top(8, to: header)
        textFieldContainerLeading = textFieldContainer.leading(12)
        textFieldContainer.height(44)
        
        addSubview(infoImageView)
        infoImageViewConstraint = infoImageView.exactSize(.init(width: 26, height: 26))
        infoImageViewConstraint?.trailing = infoImageView.trailing(16)
        infoImageView.centerVertically(to: textFieldContainer)
        infoImageViewConstraint?.leading = infoImageView.leading(20, to: textFieldContainer)
        
        addSubview(symbolsLabel)
        symbolsLabelConstraints = symbolsLabel.stickToSuperviewEdges([.left, .right, .bottom], insets: .init(top: 0, left: 12, bottom: 16, right: 12))
        symbolsLabelConstraints?.top = symbolsLabel.top(8, to: textFieldContainer)
        symbolsLabelConstraints?.width = symbolsLabel.height(0, priority: .required)
    }
    
    public func update(
        placeholder: String? = nil,
        value: String? = nil,
        header: String? = nil,
        isEditable: Bool = true,
        textChanged: ((String?) -> Void)? = nil,
        deleteAction: Action? = nil,
        maxSymbols: Int? = nil,
        keyboardType: UIKeyboardType = .default,
        textContentType: UITextContentType? = nil,
        isRequired: Bool = true,
        width: CGFloat? = nil,
        leadingInset: CGFloat = 12,
        willBeginEditing: Action? = nil,
        infoCallback: Action? = nil,
        tapCallback: Action? = nil
    ) {
        textField.attributedPlaceholder = NSAttributedString(string: placeholder ?? "", attributes: [.font: Font.main(weight: .regular).withSize(16), .foregroundColor: Color.Base.placeholder])
        textField.text = value
        self.textChanged = textChanged
        self.maxSymbols = maxSymbols
        textField.isUserInteractionEnabled = tapCallback != nil ? false : isEditable
        textField.textColor = isEditable ? Color.Base.label : Color.Base.secondary
        textField.keyboardType = keyboardType
        textField.textContentType = textContentType
        textField.isEnabled = textField.isUserInteractionEnabled
        textFieldContainerLeading?.constant = leadingInset
        headerConstraints?.leading?.constant = leadingInset
        self.willBeginEditing = willBeginEditing
        self.isRequired = isRequired
        widthConstant = width
        self.infoCallback = infoCallback
        
        updateHeaderView(text: header)
        updateSymbolsLabelText()
        updateSymbolsLabelView()
        updateInfoViewConstraints()
        
        layoutIfNeeded()
    }
    
    private func updateSymbolsLabelText() {
        if let maxSymbols = maxSymbols {
            let symbols = textField.text?.count ?? 0
            symbolsLabel.text = "\(symbols)/\(maxSymbols)"
            if symbols > maxSymbols || symbols == 0 && isRequired {
                symbolsLabel.textColor = Color.Base.red
            } else {
                symbolsLabel.textColor = Color.Base.secondary
            }
        } else {
            symbolsLabel.text = nil
        }
    }
    
    private func updateSymbolsLabelView() {
        if let _ = maxSymbols {
            symbolsLabelConstraints?.height?.isActive = false
            symbolsLabelConstraints?.bottom?.constant = -16
        } else {
            symbolsLabelConstraints?.height?.isActive = true
            symbolsLabelConstraints?.bottom?.constant = -4
        }
    }
    
    
    private func updateHeaderView(text: String?) {
        if let text = text {
            header.text = text
            headerConstraints?.height?.isActive = false
            headerConstraints?.top?.constant = 14
        } else {
            headerConstraints?.height?.isActive = true
            headerConstraints?.top?.constant = 4
        }
    }
    
    private func updateInfoViewConstraints() {
        if infoCallback == nil {
            infoImageViewConstraint?.leading?.constant = 0
            infoImageViewConstraint?.width?.constant = 0
        } else {
            infoImageViewConstraint?.leading?.constant = 20
            infoImageViewConstraint?.width?.constant = 26
        }
    }
    
}

extension TextFieldView: UITextFieldDelegate {
    
    open func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        willBeginEditing?()
        return true
    }
    
    open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
