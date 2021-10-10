//
//  TimeTest.swift
//  HSEUIComponentsTests
//
//  Created by Mikhail on 06.05.2021.
//

import XCTest
@testable import HSEUIComponents

class TimeTest: XCTestCase {
    
    func testIncorrectInitWithString() {
        var str = "22:04:1343"
        XCTAssertNil(Time(from: str))
        
        str = "sfsfs"
        XCTAssertNil(Time(from: str))
    }

    func testCorrectInitWithString() {
        var str = "22:04"
        assert(Time(from: str) == Time(hour: 22, minute: 4))
        
        str = " 22:04 "
        assert(Time(from: str) == Time(hour: 22, minute: 4))
    }
    
    func testInitWithDate() {
        var date = Date(timeIntervalSince1970: 1621085732)
        assert(Time(from: date) == Time(hour: 16, minute: 35))
        
        date = Date(timeIntervalSince1970: 0)
        assert(Time(from: date) == Time(hour: 3, minute: 0))
    }
    
    func testCompareOperations() {
        var first = Time(hour: 9, minute: 35)
        var second = Time(hour: 23, minute: 59)
        
        XCTAssertTrue(first < second)
        XCTAssertTrue(second > first)
        XCTAssertTrue(second != first)
        
        second = Time(hour: 9, minute: 35)
        XCTAssertTrue(second == first)
        
        first = Time(from: 460)
        second = Time(from: 450)
        XCTAssertTrue(first > second)
        XCTAssertTrue(second < first)
        XCTAssertTrue(second != first)
    }

}
