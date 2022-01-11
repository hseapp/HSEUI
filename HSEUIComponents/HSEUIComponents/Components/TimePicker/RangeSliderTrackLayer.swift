import UIKit
import HSEUI

class RangeSliderTrackLayer: CALayer {
    weak var rangeSlider: RangeSlider?
    
    override func draw(in ctx: CGContext) {
        guard let slider = rangeSlider else {
            return
        }

        let lowerValuePosition = slider.positionForValue(slider._lowerValue)
        let upperValuePosition = slider.positionForValue(slider._upperValue)
        let thumbHeight: CGFloat = 14
        let thumbWidth: CGFloat = 3
        let thumbBorderOffset: CGFloat = 3
        let leftThumbOffset = lowerValuePosition + thumbBorderOffset
        let rightThumbOffset = upperValuePosition - thumbBorderOffset - thumbWidth
        let thumbTopOffset = (bounds.height - thumbHeight) / 2
        
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        ctx.addPath(path.cgPath)
        
        ctx.setFillColor(slider.trackTintColor.cgColor)
        let rect = CGRect(x: lowerValuePosition, y: 0,
                          width: upperValuePosition - lowerValuePosition,
                          height: bounds.height)
        ctx.fill(rect)

        // add thumbs
        func addThumb(xOffset: CGFloat) {
            ctx.setFillColor(Color.TimePicker.thumb.cgColor)
            let rect = CGRect(x: xOffset, y: thumbTopOffset,
                                       width: thumbWidth,
                                       height: thumbHeight)
            ctx.fill(rect)
        }

        addThumb(xOffset: leftThumbOffset)
        addThumb(xOffset: rightThumbOffset)
    }
}
