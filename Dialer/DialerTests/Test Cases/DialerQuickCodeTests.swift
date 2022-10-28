//
//  DialerQuickCodeTests.swift
//  DialerTests
//
//  Created by Cédric Bahirwe on 28/10/2022.
//

import XCTest
import Dialer

final class DialerQuickCodeTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testQuickCodesSuit() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.

        try testMomoQuickCode()
        try testElectricityQuickCode()
        try testOtherQuickCode()
    }

    func testMomoQuickCode() throws {
        let pin = makeCodePin(20_000)
        let code1 =  DialerQuickCode.mobileWalletBalance(code: pin)
        XCTAssertEqual(code1.ussd, "*182*6*1*20000#")
        XCTAssertEqual(code1.ussd, "*182*6*1*\(pin.asString)#")

        let code2 =  DialerQuickCode.mobileWalletBalance(code: nil)
        XCTAssertEqual(code2.ussd, "*182*6*1#")
    }


    func testElectricityQuickCode() throws {
        let pin = makeCodePin(10_000)
        let meter = "1000000"
        let amount = 1_000
        let code1 =  DialerQuickCode.electricity(meter: meter,
                                                 amount: amount,
                                                 code: pin)
        XCTAssertEqual(code1.ussd, "*182*2*2*1*1*1000000*1000*10000#")
        XCTAssertEqual(code1.ussd, "*182*2*2*1*1*1000000*1000*\(pin.asString)#")

        let code2 =  DialerQuickCode.electricity(meter: meter,
                                                 amount: amount,
                                                 code: nil)
        XCTAssertEqual(code2.ussd, "*182*2*2*1*1*1000000*1000#")
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
