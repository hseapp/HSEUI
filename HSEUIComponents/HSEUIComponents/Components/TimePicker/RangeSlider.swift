import UIKit
import HSEUI

protocol RangeSliderPresentable: UIControl {
    var lowerValue: Time { get }
    var upperValue: Time { get }
    var timePicker: TimePickerPresentable? { get set }
    
    func setLowerValue(_ time: Time)
    func setUpperValue(_ time: Time)
    func updateLayerFrames()
}

class RangeSlider: UIControl, RangeSliderPresentable {

    private enum Constants {
        static let thumbWidth: CGFloat = 25

        static let borderScrollWidth: CGFloat = 30
    }
    
    private(set) var lowerValue: Time = .midnight
    
    private(set) var upperValue: Time = .midnight
    
    private let _minimumValue: CGFloat = 0
    
    private let _maximumValue: CGFloat = 1

    private var isLeftThumbActive = false

    private var isRightThumbActive = false
    
    private(set) var _lowerValue: CGFloat = 0.2 {
        didSet {
            lowerValue = convertToTime(_lowerValue)
        }
    }
    
    private(set) var _upperValue: CGFloat = 0.8 {
        didSet {
            upperValue = convertToTime(_upperValue)
        }
    }
    
    weak var timePicker: TimePickerPresentable?
    
    var trackTintColor: UIColor {
        timePicker?.trackTintColor ?? Color.Base.red
    }
    
    private let trackLayer = RangeSliderTrackLayer()
    
    private var previousLocation = CGPoint()

    private var thumbWidthValue: CGFloat {
        Constants.thumbWidth / bounds.width
    }
    
    private var trackFrame: CGRect {
        .init(x: 0, y: timePicker?.scheduleTopOffset ?? 0, width: bounds.width, height: timePicker?.scheduleHeight ?? 0)
    }

    var minDurationValue: CGFloat {
        convertTime(timePicker?.minimumDuration ?? .init(from: 0))
    }
    
    var maxDurationValue: CGFloat {
        convertTime(timePicker?.maximumDuration ?? .init(from: 0))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        isExclusiveTouch = true
        
        trackLayer.rangeSlider = self
        trackLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(trackLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayerFrames()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        trackLayer.setNeedsDisplay()
    }
    
    func updateLayerFrames() {
        guard bounds.width != 0 else { return }
        trackLayer.frame = trackFrame
        trackLayer.setNeedsDisplay()
    }
    
    func positionForValue(_ value: CGFloat) -> CGFloat {
        return bounds.width * value
    }
    
    private func thumbOriginForValue(_ value: CGFloat) -> CGPoint {
        let x = positionForValue(value)
        return CGPoint(x: x, y: timePicker?.scheduleTopOffset ?? 0)
    }

    private func convertToTime(_ value: CGFloat) -> Time {
        guard let timePicker = timePicker else { return .midnight }
        let duration = (timePicker.timeBounds.end - timePicker.timeBounds.start).toMinutes()
        return Time(from: Int(round(value * CGFloat(duration)))) + timePicker.timeBounds.start
    }
    
    private func convertFromTime(_ time: Time) -> CGFloat {
        guard let timePicker = timePicker else { return 0 }
        let duration = (timePicker.timeBounds.end - timePicker.timeBounds.start).toMinutes()
        return CGFloat((time - timePicker.timeBounds.start).toMinutes()) / CGFloat(duration)
    }
    
    func setLowerValue(_ time: Time) {
        lowerValue = time
        _lowerValue = convertFromTime(time)
    }
    
    func setUpperValue(_ time: Time) {
        upperValue = time
        _upperValue = convertFromTime(time)
    }

    // MARK: - helpers
    func convertTime(_ time: Time) -> CGFloat {
        guard let timePicker = timePicker else { return 0 }
        let duration = (timePicker.timeBounds.end - timePicker.timeBounds.start).toMinutes()
        return CGFloat(time.toMinutes()) / CGFloat(duration)
    }

    func boundValue(_ value: CGFloat, toLowerValue lowerValue: CGFloat,
                            upperValue: CGFloat) -> CGFloat {
        return min(max(value, lowerValue), upperValue)
    }

    func changeLowerValue(_ deltaValue: CGFloat) {
        _lowerValue += deltaValue
        _lowerValue = boundValue(_lowerValue, toLowerValue: max(_minimumValue, _upperValue - maxDurationValue), upperValue: _upperValue - minDurationValue)
    }

    func changeUpperValue(_ deltaValue: CGFloat) {
        _upperValue += deltaValue
        _upperValue = boundValue(_upperValue, toLowerValue: _lowerValue + minDurationValue, upperValue: min(_maximumValue, _lowerValue + maxDurationValue))
    }
    
    // MARK: - move slider
    private var isMovingSlider = false

    private var displayLink: CADisplayLink?

    private var offset: CGFloat?

    private func moveSliderRight() {
        moveSlider(offset: 2)
    }

    private func moveSliderLeft() {
        moveSlider(offset: -2)
    }

    private func moveSlider(offset: CGFloat) {
        guard !isMovingSlider else { return }
        isMovingSlider = true
        self.offset = offset

        displayLink = CADisplayLink(target: self, selector: #selector(animateSliderMove))
        displayLink?.add(to: RunLoop.main, forMode: .common)
    }

    private func stopMovingSlider() {
        isMovingSlider = false
        displayLink?.invalidate()
        displayLink = nil
        offset = nil
    }

    @objc private func animateSliderMove(displaylink: CADisplayLink) {
        guard let offset = offset, isMovingSlider else { return }

        let deltaValue = offset / self.bounds.width

        let location = previousLocation.x + offset
        if location < 0 || location > bounds.width {
            return
        }
        
        let previousLowerValue = _lowerValue
        let previousUpperValue = _upperValue
        if isLeftThumbActive && offset < 0 {
            changeLowerValue(deltaValue)
        } else if isRightThumbActive && offset > 0 {
            changeUpperValue(deltaValue)
        } else {
            changeLowerValue(deltaValue)
            changeUpperValue(deltaValue)
        }
        if _upperValue == previousUpperValue && _lowerValue == previousLowerValue {
            stopMovingSlider()
            return
        }
        
        timePicker?.changeContentOffset(offset)
        
        previousLocation.x += offset
        
        sendActions(for: .valueChanged)
        updateLayerFrames()
    }

}

extension RangeSlider {
    
    private func isLeftThumbContainsTouch(_ touch: UITouch) -> Bool {
        let location = touch.location(in: self)
        let locationValue = location.x / bounds.width
        return _lowerValue - thumbWidthValue <= locationValue && locationValue <= _lowerValue + thumbWidthValue
    }
    
    private func isRightThumbContainsTouch(_ touch: UITouch) -> Bool {
        let location = touch.location(in: self)
        let locationValue = location.x / bounds.width
        return _upperValue - thumbWidthValue <= locationValue && locationValue <= _upperValue + thumbWidthValue
    }
    
    private func isBodyContainsTouch(_ touch: UITouch) -> Bool {
        let location = touch.location(in: self)
        let locationValue = location.x / bounds.width
        return locationValue >= _lowerValue - thumbWidthValue && locationValue <= _upperValue + thumbWidthValue
    }
 
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)

        previousLocation = touch.location(in: self)

        if isLeftThumbContainsTouch(touch) {
            isLeftThumbActive = true
            return true
        } else if isRightThumbContainsTouch(touch) {
            isRightThumbActive = true
            return true
        } else if isBodyContainsTouch(touch) {
            return true
        }

        return false
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.continueTracking(touch, with: event)
        
        let location = touch.location(in: self)

        guard let timePicker = timePicker, location.y >= trackFrame.origin.y else { return false }
        
        let deltaLocation = location.x - previousLocation.x
        let deltaValue = (_maximumValue - _minimumValue) * deltaLocation / bounds.width

        let timePickerLocation = touch.location(in: timePicker).x
        if timePickerLocation <= Constants.borderScrollWidth && deltaLocation < 0 {
            moveSliderLeft()
        } else if timePickerLocation >= timePicker.bounds.width - Constants.borderScrollWidth && deltaLocation > 0 {
            moveSliderRight()
        } else {
            stopMovingSlider()
        }

        if isMovingSlider { return true }

        if isLeftThumbActive {
            changeLowerValue(deltaValue)
        } else if isRightThumbActive {
            changeUpperValue(deltaValue)
        } else {
            changeLowerValue(deltaValue)
            changeUpperValue(deltaValue)
        }
        
        previousLocation = location

        sendActions(for: .valueChanged)
        updateLayerFrames()
        
        return true
    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        isLeftThumbActive = false
        isRightThumbActive = false
        stopMovingSlider()
        autoscrollToNearestValue()
    }
    
    private func calculateNewTime(_ value: CGFloat) -> Time {
        let originValue = convertToTime(value).toMinutes()
        let minutes = Int(round(CGFloat(originValue) / 10.0) * 10)
        return Time(from: minutes)
    }
    
    func autoscrollToNearestValue() {
        setLowerValue(calculateNewTime(_lowerValue))
        setUpperValue(calculateNewTime(_upperValue))
        
        sendActions(for: .valueChanged)
        updateLayerFrames()
        
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }
    
}

extension RangeSlider {
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let location = gestureRecognizer.location(in: self)
        let locationValue = location.x / bounds.width
        return locationValue < _lowerValue - thumbWidthValue ||
            locationValue > _upperValue + thumbWidthValue ||
            location.y < trackFrame.origin.y
    }
    
}
