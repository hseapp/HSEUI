import UIKit
import HSEUI

public protocol TimePickerPresentable: UIView {
    var scheduleHeight: CGFloat { get }
    var topOffset: CGFloat { get }
    var scheduleTopOffset: CGFloat { get }
    var intersectsWithSchedule: Bool { get }
    var timeBounds: TimeBounds { get }
    var minimumDuration: Time { get }
    var maximumDuration: Time { get }
    var trackTintColor: UIColor { get }

    func changeContentOffset(_ value: CGFloat)
}

public enum TimeSeparator: Int {
    case hour = 60
    case half = 30
    case quarter = 15
    case ten = 10
}

public final class TimePickerViewModel: CellViewModel {
    
    public var sliderTimeBounds: TimeBounds {
        didSet {
            apply(type: TimePickerView.self) { (view) in
                view.setParams(sliderTimeBounds: sliderTimeBounds)
            }
        }
    }
    
    public init(
        schedule: [TimeBounds],
        showSlider: Bool = false,
        showCurrentTimeIndicator: Bool = true,
        timeBounds: TimeBounds = .workHours,
        sliderTimeBounds: TimeBounds = .workHours,
        isTimeInPastAllowed: Bool = true,
        separators: [TimeSeparator] = [.hour, .half],
        minimumDuration: Time? = nil,
        maximumDuration: Time? = nil,
        didPickNewTime: ((TimeBounds, Bool) -> ())? = nil
    ) {
        self.sliderTimeBounds = sliderTimeBounds
        super.init(view: TimePickerView.self)
        let configurator = CellViewConfigurator<TimePickerView>.builder()
            .setUseChevron(false)
            .setConfigureView({ view in
                view.setParams(schedule: schedule, showSlider: showSlider, showCurrentTimeIndicator: showCurrentTimeIndicator, timeBounds: timeBounds, sliderTimeBounds: self.sliderTimeBounds, isTimeInPastAllowed: isTimeInPastAllowed, separators: separators, minimumDuration: minimumDuration, maximumDuration: maximumDuration, didPickNewTime: didPickNewTime)
            })
            .build()
        updateConfigurator(configurator)
    }
}

open class TimePickerView: UIView, TimePickerPresentable {
    
    // MARK: - properties
    private(set) var schedule: [TimeBounds] = []
    
    public private(set) var timeBounds: TimeBounds = .workHours

    private(set) var timeSeparator: [TimeSeparator] = [.hour, .half]
    
    public var didPickNewTime: ((TimeBounds, Bool) -> ())?
    
    public private(set) var intersectsWithSchedule: Bool = false
    
    private(set) var sliderTimeBounds: TimeBounds {
        set {
            guard sliderTimeBounds != TimeBounds(start: newValue.start, end: newValue.end) else { return }
            slider.setUpperValue(newValue.end)
            slider.setLowerValue(newValue.start)
        }
        get {
            .init(start: slider.lowerValue, end: slider.upperValue)
        }
    }
    
    public private(set) var minimumDuration: Time = .init(hour: 0, minute: 20)
    
    private var _maximumDuration: Time?
    
    public var maximumDuration: Time {
        _maximumDuration ?? (timeBounds.end - timeBounds.start)
    }
    
    public var isAvailableTime: Bool {
        !(!isTimeInPastAllowed && sliderTimeBounds.start < Time(from: Date()) || intersectsWithSchedule)
    }
    
    public var showCurrentTimeIndicator: Bool = true
    
    private var isTimeInPastAllowed: Bool = true
    
    public var trackTintColor: UIColor {
        isAvailableTime ? Color.TimePicker.green : Color.TimePicker.red
    }
    
    private enum SliderConstraints {
        
        static let scheduleHeight: CGFloat = 65
        
        static let topOffset: CGFloat = 10
        
        static let contentOffset: CGFloat = 16
        
        static let sliderHeight: CGFloat = 80
        
        static let smallTickHeight: CGFloat = 32
        
        static let bottomOffset: CGFloat = 19
        
        static let timeTicksDist: CGFloat = 45
        
        static let separatorWidth: CGFloat = 1
        
        static let currentTimeIndicatorHeight: CGFloat = 88

        static var diagonalLineSpacing: CGFloat {
            timeCellWidth / 5
        }
        
        static var totalHeight: CGFloat {
            sliderHeight + topOffset + bottomOffset
        }
        
        static var scheduleTopOffset: CGFloat {
            topOffset + sliderHeight - scheduleHeight
        }
        
        static var smallTickTopOffset: CGFloat {
            topOffset + (sliderHeight - smallTickHeight)
        }
        
        static var timeCellWidth: CGFloat {
            (timeTicksDist + separatorWidth) * 2
        }
    }
    
    public let scheduleHeight: CGFloat = SliderConstraints.scheduleHeight
    
    public let topOffset: CGFloat = SliderConstraints.topOffset
    
    public let scheduleTopOffset: CGFloat = SliderConstraints.scheduleTopOffset
    
    private var imageWidth: CGFloat {
        let totalTime = timeBounds.end - timeBounds.start + 1
        let timeTicksDistCoef: CGFloat = SliderConstraints.timeTicksDist / 29.0
        let ticksCounter = totalTime.hour * 2 + (totalTime.minute >= 30 ? 1 : 0)
        return CGFloat(totalTime.toMinutes() - ticksCounter) * timeTicksDistCoef + CGFloat(ticksCounter) * SliderConstraints.separatorWidth
    }
    
    // MARK: - ui elements
    private lazy var scrollView: UIScrollView = {
        let sv = TimePickerScrollView(frame: .zero)
        sv.contentInset = .init(top: 0, left: SliderConstraints.contentOffset, bottom: 0, right: SliderConstraints.contentOffset)
        sv.rangeSlider = slider
        return sv
    }()
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFit
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var slider: RangeSliderPresentable = {
        let slider = RangeSlider()
        slider.timePicker = self
        slider.addTarget(self, action: #selector(handleSliderValueChange), for: .valueChanged)
        slider.updateLayerFrames()
        return slider
    }()
    
    // MARK: - init
    public init() {
        super.init(frame: .zero)
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - life cycle
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        imageView.image = drawBackground()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        scrollToCurrentTime()
    }
    
    // MARK: - commonInit
    private func commonInit() {
        backgroundColor = Color.Base.mainBackground
        
        addSubview(scrollView)
        scrollView.stickToSuperviewEdges(.all)
        
        scrollView.addSubview(imageView)
        imageView.stickToSuperviewEdges([.left, .right])
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        imageView.addSubview(slider)
        slider.stickToSuperviewEdges(.all)
        
        height(SliderConstraints.totalHeight)
        
        imageView.image = drawBackground()
    }
    
    // MARK: - update
    public func setParams(
        schedule: [TimeBounds]? = nil,
        showSlider: Bool? = nil,
        showCurrentTimeIndicator: Bool? = nil,
        timeBounds: TimeBounds? = nil,
        sliderTimeBounds: TimeBounds? = nil,
        isTimeInPastAllowed: Bool? = nil,
        separators: [TimeSeparator]? = nil,
        minimumDuration: Time? = nil,
        maximumDuration: Time? = nil,
        didPickNewTime: ((TimeBounds, Bool) -> ())? = nil
    ) {
        if let schedule = schedule {
            self.schedule = schedule
        }
        if let showSlider = showSlider {
            slider.isHidden = !showSlider
        }
        if let showCurrentTimeIndicator = showCurrentTimeIndicator {
            self.showCurrentTimeIndicator = showCurrentTimeIndicator
        }
        if let minimumDuration = minimumDuration {
            self.minimumDuration = minimumDuration
        }
        if let maximumDuration = maximumDuration {
            self._maximumDuration = maximumDuration
        }
        if let timeBounds = timeBounds, timeBounds.end > timeBounds.start {
            // NOTE: - should be before `sliderTimeBounds`
            self.timeBounds = timeBounds
        }
        if let sliderTimeBounds = sliderTimeBounds, sliderTimeBounds.end > sliderTimeBounds.start {
            self.sliderTimeBounds = sliderTimeBounds
        }
        if let isTimeInPastAllowed = isTimeInPastAllowed {
            self.isTimeInPastAllowed = isTimeInPastAllowed
        }
        if let separators = separators {
            self.timeSeparator = separators
        }
        if let didPickNewTime = didPickNewTime {
            self.didPickNewTime = didPickNewTime
        }
        updateUI()
    }
    
    private func updateUI() {
        imageView.image = drawBackground()
        intersectsWithSchedule = !schedule.allSatisfy({ !sliderTimeBounds.intersect($0) })
        slider.updateLayerFrames()
    }
    
    // MARK: - helpers
    private func calculateOffset(from date: Date) -> CGFloat? {
        return calculateOffset(time: Date().toTime())
    }
    
    private func calculateOffset(time: Time) -> CGFloat? {
        guard time >= timeBounds.start && time <= timeBounds.end else { return nil }
        var offset = SliderConstraints.timeCellWidth * CGFloat(time.hour - timeBounds.start.hour)
        if time.minute > 0 {
            offset += SliderConstraints.timeCellWidth * CGFloat(time.minute) / CGFloat(60)
        }
        return offset
    }
    
    private func scrollToCurrentTime() {
        guard var offset = calculateOffset(from: Date()) else { return }
        offset -= UIScreen.main.bounds.width / 2
        offset = min(max(-SliderConstraints.contentOffset, offset), imageWidth + SliderConstraints.contentOffset - bounds.width)
        scrollView.setContentOffset(.init(x: offset, y: 0), animated: true)
    }
    
    // MARK: - slider
    private var previousSliderTimeBounds: TimeBounds?
    
    private let hapticFeedbackDistance: Time = .init(from: 10)
    
    @objc private func handleSliderValueChange() {
        intersectsWithSchedule = !schedule.allSatisfy({ !sliderTimeBounds.intersect($0) })
        
        if let previousValue = previousSliderTimeBounds {
            if abs(previousValue.start.toMinutes() - sliderTimeBounds.start.toMinutes()) > hapticFeedbackDistance.toMinutes() ||
                abs(previousValue.end.toMinutes() - sliderTimeBounds.end.toMinutes()) > hapticFeedbackDistance.toMinutes() {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                previousSliderTimeBounds = sliderTimeBounds
            }
        } else {
            previousSliderTimeBounds = timeBounds
        }
        
        didPickNewTime?(sliderTimeBounds, isAvailableTime)
    }

    public func changeContentOffset(_ value: CGFloat) {
        let offset = scrollView.contentOffset.x
        if offset + value + SliderConstraints.contentOffset < 0 ||
            offset + value - SliderConstraints.contentOffset > scrollView.contentSize.width - bounds.width {
            return
        }
        scrollView.contentOffset.x += value
    }
    
    // MARK: - draw image
    private func drawBackground() -> UIImage {
        
        let size: CGSize = .init(width: imageWidth, height: SliderConstraints.totalHeight)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { ctx in
            
            func drawRect(origin: CGPoint, size: CGSize, color: UIColor = Color.TimePicker.separator) {
                color.setFill()
                UIBezierPath(rect: CGRect(origin: origin, size: size)).fill()
            }
            
            func drawTime(time: String, origin: CGPoint) {
                let font = Font.main(weight: .regular).withSize(10)
                
                let attrs = [NSAttributedString.Key.font: font,
                             NSAttributedString.Key.foregroundColor: Color.Base.secondary]
                
                time.draw(with: CGRect(origin: origin, size: .init(width: 40, height: 12)), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
            }

            // schedule
            typealias Bounds = (start: CGFloat, end: CGFloat)
            var scheduleBounds: [Bounds] = []
            for data in schedule {
                let boundedTime: TimeBounds = .init(
                    start: max(data.start, timeBounds.start),
                    end: min(data.end, timeBounds.end)
                )
                if let start = calculateOffset(time: boundedTime.start), let end = calculateOffset(time: boundedTime.end) {
                    scheduleBounds.append((start, end))
                    let width = end - start
                    drawRect(
                        origin: .init(x: start, y: SliderConstraints.scheduleTopOffset),
                        size: .init(width: width, height: SliderConstraints.scheduleHeight),
                        color: Color.TimePicker.schedule
                    )
                }
            }
            
            // bottom line
            drawRect(origin: .init(x: 0, y: SliderConstraints.sliderHeight + SliderConstraints.topOffset), size: .init(width: imageWidth, height: SliderConstraints.separatorWidth))
            
            // separators
            var ticksCounter: Int = 0
            let timeTicksDistCoef: CGFloat = SliderConstraints.timeTicksDist / 29.0
            for i in timeBounds.start.toMinutes() ... timeBounds.end.toMinutes() {
                let offset: CGFloat = CGFloat(i - timeBounds.start.toMinutes() - ticksCounter) * timeTicksDistCoef + CGFloat(ticksCounter) * SliderConstraints.separatorWidth
                if i % 60 == 0 {
                    if timeSeparator.contains(.hour) {
                        let origin: CGPoint = .init(x: offset,
                                                    y: SliderConstraints.topOffset)
                        drawRect(origin: origin, size: .init(width: SliderConstraints.separatorWidth, height: SliderConstraints.sliderHeight))
                    }
                    
                    let textOrigin: CGPoint = .init(x: offset + 9, y: 8)
                    drawTime(time: "\(Int(i / 60)):00", origin: textOrigin)
                    ticksCounter += 1
                } else if timeSeparator.contains(.half) && i % 30 == 0 ||
                            timeSeparator.contains(.quarter) && i % 15 == 0 ||
                            timeSeparator.contains(.ten) && i % 10 == 0 {
                    let origin: CGPoint = .init(x: offset,
                                                y: SliderConstraints.smallTickTopOffset)
                    drawRect(origin: origin, size: .init(width: SliderConstraints.separatorWidth, height: SliderConstraints.smallTickHeight))
                    ticksCounter += 1
                }
            }

            // draw diagonal lines
            if let start = calculateOffset(time: timeBounds.start), let end = calculateOffset(time: timeBounds.end) {
                ctx.cgContext.setStrokeColor(Color.TimePicker.separator.cgColor)
                var current = start

                while current < end + SliderConstraints.scheduleHeight {
                    for bounds in scheduleBounds {
                        if current > bounds.start && current < (bounds.end + SliderConstraints.scheduleHeight) {
                            let linesStart = current - SliderConstraints.scheduleHeight

                            var firstPoint: CGPoint = .init(
                                x: linesStart,
                                y: SliderConstraints.scheduleTopOffset
                            )
                            var secondPoint: CGPoint = .init(
                                x: firstPoint.x + SliderConstraints.scheduleHeight,
                                y: SliderConstraints.scheduleTopOffset + SliderConstraints.scheduleHeight
                            )

                            if firstPoint.x < bounds.start {
                                firstPoint.y += bounds.start - firstPoint.x
                                firstPoint.x = bounds.start
                            }
                            if secondPoint.x > bounds.end {
                                secondPoint.y -= (secondPoint.x - bounds.end)
                                secondPoint.x = bounds.end
                            }

                            ctx.cgContext.move(to: firstPoint)
                            ctx.cgContext.addLine(to: secondPoint)

                            ctx.cgContext.strokePath()
                        }
                    }
                    current += SliderConstraints.diagonalLineSpacing
                }
            }
            
            // current time indicator
            if showCurrentTimeIndicator, let offset = calculateOffset(from: Date()) {
                drawRect(
                    origin:
                        .init(x: offset, y: SliderConstraints.topOffset),
                    size: .init(width: SliderConstraints.separatorWidth, height: SliderConstraints.currentTimeIndicatorHeight),
                    color: Color.Base.brandTint
                )
                
                Color.Base.brandTint.setFill()
                UIBezierPath(
                    ovalIn: CGRect(
                        origin: .init(x: offset - 2, y: SliderConstraints.topOffset + SliderConstraints.currentTimeIndicatorHeight),
                        size: .init(width: 5, height: 5)
                    )
                ).fill()
            }
            
        }
    }
    
}
