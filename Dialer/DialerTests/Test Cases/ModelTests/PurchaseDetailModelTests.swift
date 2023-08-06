//
//  PurchaseDetailModelTests.swift
//  DialerTests
//
//  Created by Cédric Bahirwe on 07/03/2023.
//

import XCTest
@testable import Dialer

final class PurchaseDetailModelTests: XCTestCase {
    
    func testUSSDCodesSuite()  throws {
        try testPinLessPurchase()
        try testPinnedPurchaseAmountOutOfRangeForPinAppending()
        try testPinnedPurchaseAmountInRangeForPinAppending()
    }
    
    func testPinLessPurchase() throws {
        let purchase = PurchaseDetailModel(amount: 1000)
        let expectedUnpinCode = "*182*2*1*1*1*1000#"
        
        XCTAssertEqual(expectedUnpinCode, purchase.getFullUSSDCode(with: nil))
    }
    
    func testPinnedPurchaseSmallAmount() throws {
        let pin = try Dialer.CodePin(22000)
        let purchase = PurchaseDetailModel(amount: 100)
        
        let expectedPinnedCode = "*182*2*1*1*1*100#"
        XCTAssertEqual(expectedPinnedCode, purchase.getFullUSSDCode(with: pin))
    }
    
    func testPinnedPurchaseBigAmount() throws {
        let pin = try Dialer.CodePin(22000)
        let purchase = PurchaseDetailModel(amount: 1000)
        
        let expectedPinnedCode = "*182*2*1*1*1*1000#"
        XCTAssertEqual(expectedPinnedCode, purchase.getFullUSSDCode(with: pin))
    }

    func testPinnedPurchaseAmountOutOfRangeForPinAppending() throws {
        let pin = try Dialer.CodePin(22000)
        let purchase = PurchaseDetailModel(amount: 100)

        let expectedPinnedCode = "*182*2*1*1*1*100#"
        XCTAssertEqual(expectedPinnedCode, purchase.getFullUSSDCode(with: pin), "For the range out of 10 to 99, pin should not be appended to the string")
    }
    
    func testPinnedPurchaseAmountInRangeForPinAppending() throws {
        let pin = try Dialer.CodePin(22000)
        let amount = 50
        let purchase = PurchaseDetailModel(amount: amount)

        let expectedPinnedCode = "*182*2*1*1*1*\(amount)*\(pin.asString)#"
        XCTAssertEqual(expectedPinnedCode, purchase.getFullUSSDCode(with: pin), "For the range of 10 to 99, the pin is appended to the string")
    }
}
