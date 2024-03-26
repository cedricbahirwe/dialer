//
//  DialerQuickCodeTests.swift
//  DialerTests
//
//  Created by Cédric Bahirwe on 28/10/2022.
//

import XCTest
@testable import Dialer

final class DialerQuickCodeTests: XCTestCase {

    func testQuickCodesSuite() throws {
        try testMomoQuickCode()
        try testElectricityQuickCode()
        try testOtherQuickCode()
    }

    func testMomoQuickCode() throws {
        let code1 =  DialerQuickCode.mobileWalletBalance
        XCTAssertEqual(code1.ussd, "*182*6*1#")
    }


    func testElectricityQuickCode() throws {
        let meter = "1000000"
        let amount = 1_000
        let code1 =  DialerQuickCode.electricity(meter: meter,
                                                 amount: amount)
        XCTAssertEqual(code1.ussd, "*182*2*2*1*1*1000000*1000#")
    }

    func testOtherQuickCode() throws {
        let code1 =  DialerQuickCode.other("*151#")
        let code2 =  DialerQuickCode.other("*151*121#")
        let code3 =  DialerQuickCode.other("*151*1*1#")
        XCTAssertEqual(code1.ussd, "*151#")
        XCTAssertEqual(code2.ussd, "*151*121#")
        XCTAssertEqual(code3.ussd, "*151*1*1#")
    }

    func makeCodePin(_ value: Int) -> CodePin {
        try! CodePin(value)
    }

    func makeCodePin(_ value: String) -> CodePin {
        try! CodePin(value)
    }
}
