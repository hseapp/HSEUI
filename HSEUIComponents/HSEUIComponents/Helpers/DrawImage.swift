import UIKit
import HSEUI

public func drawImage(size: CGSize,
               image: UIImage?,
               imageSize: CGSize,
               backgroundColor: UIColor = .clear,
               rounded: Bool = false,
               roundedImage: Bool = false) -> UIImage {
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { (_) in
        backgroundColor.setFill()
        
        if rounded {
            UIBezierPath(ovalIn: CGRect(origin: .zero, size: size)).fill()
        } else {
            UIBezierPath(rect: CGRect(origin: .zero, size: size)).fill()
        }
        let xOffset = (size.width - imageSize.width) / 2
        let yOffset = (size.height - imageSize.height) / 2
        if let image = image {
            if roundedImage {
                UIBezierPath(ovalIn: CGRect(origin: .init(x: xOffset, y: yOffset), size: imageSize)).addClip()
            }
            image.draw(in: CGRect(origin: .init(x: xOffset, y: yOffset), size: imageSize))
        }
    }
}

public func drawAvatar(fullName: String,
                size: CGSize,
                font: UIFont = Font.header.withSize(20),
                backgroundColor: UIColor = Color.Base.imageBackground,
                textColor: UIColor = Color.Base.brandTint) -> UIImage {
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { (_) in
        backgroundColor.setFill()
        UIBezierPath(ovalIn: CGRect(origin: .zero, size: size)).fill()

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let attrs = [NSAttributedString.Key.font: font,
                     NSAttributedString.Key.paragraphStyle: paragraphStyle,
                     NSAttributedString.Key.foregroundColor: textColor]

        let yOffset = (size.height - font.lineHeight) / 2

        var string = ""
        let names = fullName.split(separator: " ")
        if names.count > 0 {
            string += names[0].first?.description.uppercased() ?? ""
        }
        if names.count > 1 {
            string += names[1].first?.description.uppercased() ?? ""
        }
        string.draw(with: CGRect(x: 0, y: yOffset, width: size.width, height: size.height), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
    }
}

