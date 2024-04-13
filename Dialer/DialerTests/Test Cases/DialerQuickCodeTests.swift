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
        try testOtherQuickCode()
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
