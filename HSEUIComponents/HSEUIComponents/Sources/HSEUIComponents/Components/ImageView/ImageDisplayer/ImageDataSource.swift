import UIKit

public enum ImageItem: Equatable {
    case image(UIImage)
    case link(String)
}

public protocol ImageDataSource: AnyObject {
    func numberOfImages() -> Int
    func imageItem(at index:Int) -> ImageItem
}

public class DefaultImageDataSource: ImageDataSource {
    private var items: [ImageItem]
    
    public init(items: [ImageItem]) {
        self.items = items
    }
    
    public func numberOfImages() -> Int {
        items.count
    }
    
    public func imageItem(at index: Int) -> ImageItem {
        items[index]
    }
}

public protocol ImageSource {
    var imageItem: ImageItem { get }
}

extension ImageView {
    
    func setItem(_ item: ImageItem) {
        switch item {
        case .link(let link):
            loadImage(link)
        case .image(let img):
            image = img
        }
    }
    
}

extension String: ImageSource {
    
    public var imageItem: ImageItem {
        return .link(self)
    }
    
}

extension UIImage: ImageSource {
    
    public var imageItem: ImageItem {
        return .image(self)
    }
    
}
