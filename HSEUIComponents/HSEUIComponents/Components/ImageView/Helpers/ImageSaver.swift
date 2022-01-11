import UIKit

public protocol IImageSaver {
    func saveImage(image: UIImage, name: String)
    func getImage(name: String) -> UIImage?
}

public class AppFolderImageSaver: IImageSaver {
    
    private static let saverQueue = DispatchQueue(label: "AppFolderImageSaver", qos: .background, attributes: .concurrent)
    
    public func saveImage(image: UIImage, name: String) {
        Self.saverQueue.async(flags: .barrier) {
            var data: Data?
            if name.contains("jpeg") || name.contains("jpg") {
                data = image.jpegData(compressionQuality: 1)
            } else if name.contains("png") {
                data = image.pngData()
            }
            guard let imgData = data else { return }

            guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
                return
            }
            do {
                try imgData.write(to: directory.appendingPathComponent(name)!)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    
    public func getImage(name: String) -> UIImage? {
        Self.saverQueue.sync {
            if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false),
               let image = UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(name).path) {
                return image
            }
            return nil
        }
    }
}

public class SessionImageSaver: IImageSaver {
    
    private static let saverQueue = DispatchQueue(label: "SessionImageSaver", qos: .background, attributes: .concurrent)
    
    private static var cache: [String: UIImage] = [:]
    
    public func saveImage(image: UIImage, name: String) {
        Self.saverQueue.async(flags: .barrier) {
            Self.cache[name] = image
        }
    }
    
    public func getImage(name: String) -> UIImage? {
        Self.saverQueue.sync {
            if let image = Self.cache[name] {
                return image
            }
            return nil
        }
    }
    
}

public class CombinedImageSaver: IImageSaver {
    
    private let sessionSaver = SessionImageSaver()
    
    private let appFolderSaver = AppFolderImageSaver()
    
    public init() { }
    
    public func saveImage(image: UIImage, name: String) {
        sessionSaver.saveImage(image: image, name: name)
        appFolderSaver.saveImage(image: image, name: name)
    }
    
    public func getImage(name: String) -> UIImage? {
        if let image = sessionSaver.getImage(name: name) {
            return image
        }
        
        if let image = appFolderSaver.getImage(name: name) {
            sessionSaver.saveImage(image: image, name: name)
            return image
        }
        
        return nil
    }
    
}
