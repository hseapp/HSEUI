import UIKit
import HSEUI

// ---------------------------------------------------------------------------------------------
// image view that supports downloading image from web

public typealias ImageCreation = () -> UIImage?

open class ImageView: UIImageView {

    // MARK: - Placeholder
    public enum Placeholder {
        
        case symbol(String, tintColor: UIColor = Color.Base.image)
        case image(UIImage)
        case `func`(ImageCreation)
        case none

        public func getImage() -> UIImage? {
            switch self {
            case .symbol(let name, let tintColor):
                return sfSymbol(name, tintColor: tintColor)
            case .image(let img):
                return img
            case .func(let creation):
                return creation()
            case .none:
                return nil
            }
        }
    }

    // MARK: - public properties
    public var isImageLoaded: Bool = false
    
    public var oldImage: UIImage?
    
    public var placeholder: Placeholder = .none {
        didSet {
            if image == nil {
                image = placeholder.getImage()
            }
        }
    }
    
    public override var image: UIImage? {
        didSet {
            if let img = image {
                oldImage = img
            } else if let placeholderImage = placeholder.getImage() {
                image = placeholderImage
            }
        }
    }
    
    // MARK: - private properties
    private var imageLoader: IImageLoader
    
    private var tapGesture: UITapGestureRecognizer
    
    private var tapAction: Action? {
        didSet {
            tapGesture.isEnabled = tapAction != nil
        }
    }

    // MARK: - init
    public init(imageSaver: IImageSaver = CombinedImageSaver()) {
        self.imageLoader = ImageLoader(imageSaver: imageSaver)
        self.tapGesture = UITapGestureRecognizer()
        
        super.init(frame: .zero)
        
        self.clipsToBounds = true
        self.contentMode = .scaleAspectFill
        
        self.addGestureRecognizer(tapGesture)
        tapGesture.addTarget(self, action: #selector(handleTap))
        tapGesture.isEnabled = false
    }

    public convenience init(placeholder: Placeholder) {
        self.init()
        
        self.placeholder = placeholder
        self.image = placeholder.getImage()
    }

    required public init?(coder: NSCoder) {
        fatalError()
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if !isImageLoaded, let placeholderImage = placeholder.getImage() {
            self.image = placeholderImage
        }
    }

    public func configureForMenuInteraction() {
        isUserInteractionEnabled = true
        self.addInteraction(UIContextMenuInteraction(delegate: self))
    }

    // MARK: - load image
    public func loadImage(_ link: String?, completion: ((Bool) -> ())? = nil) {
        self.image = self.placeholder.getImage()
        imageLoader.loadImage(link) { [weak self] (img) in
            guard let `self` = self else { return }
            if let img = img {
                self.isImageLoaded = true
                self.image = img
                completion?(true)
            } else {
                self.isImageLoaded = false
                completion?(false)
            }
        }
    }

    // MARK: - tap
    open func setTapAction(_ action: @escaping Action) {
        self.isUserInteractionEnabled = true
        self.tapAction = action
    }
    
    @objc open func handleTap() {
        tapAction?()
    }

}

private class ImageViewController: UIViewController {

    private let minContentSize: CGFloat = 200

    var image: UIImage? {
        didSet {
            imageView?.image = image
            if let image = image {
                let minDimention = min(image.size.width, image.size.height)
                if minDimention < minContentSize {
                    preferredContentSize = CGSize(
                        width: minContentSize * image.size.width / minDimention,
                        height: minContentSize * image.size.height / minDimention
                    )
                } else {
                    preferredContentSize = image.size
                }
            }
        }
    }

    private var imageView: UIImageView?

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView = UIImageView()
        view.addSubview(imageView!)
        imageView?.stickToSuperviewEdges(.all)
        imageView?.image = image
    }

}

extension ImageView: UIContextMenuInteractionDelegate {

    public func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        if image == nil { return nil }
        return UIContextMenuConfiguration(identifier: nil) { [weak self] () -> UIViewController? in
            let vc = ImageViewController()
            vc.image = self?.image
            return vc
        } actionProvider: { _ -> UIMenu? in
            return nil
        }
    }

}
