//
//  PurchaseDetailModelTests.swift
//  DialerTests
//
//  Created by Cédric Bahirwe on 07/03/2023.
//

import XCTest
@testable import Dialer

final class PurchaseDetailModelTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testUSSDCodesSuit()  throws {
        try testPinLessPurchase()
        try testPinnedPurchaseAmountOutOfRangeForPinAppending()
        try testPinnedPurchaseAmountInRangeForPinAppending()
    }

    func testPinLessPurchase() throws {
        let purchase = PurchaseDetailModel(amount: 1000)
        let expectedUnpinCode = "*182*2*1*1*1*1000#"

        XCTAssertEqual(expectedUnpinCode, purchase.getDialCode(pin: ""))

    }

    func testPinnedPurchaseAmountOutOfRangeForPinAppending() throws {
        let pin = 22000
        let purchase = PurchaseDetailModel(amount: 100)

        let expectedPinnedCode = "*182*2*1*1*1*100#"
        XCTAssertEqual(expectedPinnedCode, purchase.getDialCode(pin: "\(pin)"), "For the range of 10 to 99, pin should not be appended to the string")
    }
    
    func testPinnedPurchaseAmountInRangeForPinAppending() throws {
        let pin = 22000
        let amount = 50
        let purchase = PurchaseDetailModel(amount: amount)

        let expectedPinnedCode = "*182*2*1*1*1*\(amount)*\(pin)#"
        XCTAssertEqual(expectedPinnedCode, purchase.getDialCode(pin: "\(pin)"), "For the range of 10 to 99, the pin is appended to the string")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
