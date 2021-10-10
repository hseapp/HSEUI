//
//  RangeSliderTest.swift
//  HSEUIComponentsTests
//
//  Created by Mikhail on 06.05.2021.
//

import XCTest
@testable import HSEUIComponents

class RangeSliderTest: XCTestCase {

    func testTimeConvertions() {
        let slider: RangeSliderPresentable = RangeSlider()
        let timePicker: TimePickerPresentable = TimePickerView()
        
        slider.timePicker = timePicker
        
        for i in Time(hour: 9, minute: 30).toMinutes() ... Time(hour: 11, minute: 59).toMinutes() {
            let time = Time(from: i)
            slider.setLowerValue(time)
            XCTAssertTrue(slider.lowerValue == time)
        }
    }
    
    func testAutoscrollToNearestValue() {
        let slider = RangeSlider()
        let timePicker: TimePickerPresentable = TimePickerView()
        
        slider.timePicker = timePicker
        
        var nearestValue: Int = 0
        for i in Time(hour: 9, minute: 30).toMinutes() ... Time(hour: 11, minute: 59).toMinutes() {
            if i % 10 == 0 {
                nearestValue = i
            } else if i % 10 == 5 {
                nearestValue = i + 5
            }
            
            let time = Time(from: i)
            slider.setLowerValue(time)
            slider.autoscrollToNearestValue()
            XCTAssertTrue(slider.lowerValue.toMinutes() == nearestValue)
        }
    }

}
