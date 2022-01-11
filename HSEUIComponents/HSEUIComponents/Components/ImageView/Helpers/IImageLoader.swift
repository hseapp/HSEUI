import UIKit
import HSEUI

fileprivate extension String {
    func getContentName() -> String? {
        URL(string: self)?.lastPathComponent.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
    }
}

public protocol IImageLoader {
    func loadImage(_ link: String?, completion: @escaping (UIImage?) -> ())
}

public class ImageLoader: IImageLoader {
    private var imageSaver: IImageSaver
    
    private var lastURLUsedToLoadImage: String?
    
    public init(imageSaver: IImageSaver) {
        self.imageSaver = imageSaver
    }
    
    public func loadImage(_ link: String?, completion: @escaping (UIImage?) -> ()) {
        self.lastURLUsedToLoadImage = link

        guard let link = link, let name = link.getContentName() else {
            completion(nil)
            return
        }
        
        if let cacheImage = imageSaver.getImage(name: name) {
            completion(cacheImage)
            return
        }
        
        backgroundQueue { [weak self] in
            guard let `self` = self else { return }
            if let url = URL(string: link) {
                URLSession.shared.dataTask(with: url) { (data, _, _) in
                    guard self.lastURLUsedToLoadImage == link else { return }
                    if let data = data, let img = UIImage(data: data) {
                        mainQueue {
                            self.imageSaver.saveImage(image: img, name: name)
                            completion(img)
                        }
                    } else {
                        mainQueue {
                            completion(nil)
                        }
                    }
                }.resume()
            }
        }
    }
    
}
