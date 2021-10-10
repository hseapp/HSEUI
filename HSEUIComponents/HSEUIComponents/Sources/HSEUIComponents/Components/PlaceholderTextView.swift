import Foundation
import UIKit
import HSEUI

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
