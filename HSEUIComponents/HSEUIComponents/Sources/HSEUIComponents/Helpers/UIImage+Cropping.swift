import UIKit

public extension UIImage {
    
    func cropping(insets: UIEdgeInsets) -> UIImage {
        return cropping(
            rect: CGRect(
                origin: CGPoint(
                    x: insets.left,
                    y: insets.top
                ),
                size: CGSize(
                    width: size.width - insets.left - insets.right,
                    height: size.height - insets.top - insets.bottom
                )
            )
        )
    }
    
    func cropping(rect: CGRect) -> UIImage {
        var rect = rect
        rect.origin.x*=self.scale
        rect.origin.y*=self.scale
        rect.size.width*=self.scale
        rect.size.height*=self.scale

        let imageRef = self.cgImage!.cropping(to: rect)
        let image = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        return image
    }
    
}
