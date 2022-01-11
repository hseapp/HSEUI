import UIKit

class TimePickerScrollView: UIScrollView {
    
    weak var rangeSlider: RangeSliderPresentable?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        clipsToBounds = false
        canCancelContentTouches = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if rangeSlider?.isHidden ?? true {
            return true
        }
        return rangeSlider?.gestureRecognizerShouldBegin(gestureRecognizer) ?? false
    }
    
}
