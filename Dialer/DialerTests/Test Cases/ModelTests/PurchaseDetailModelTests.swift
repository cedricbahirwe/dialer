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
        try testPinnedPurchaseSmallAmount()
        try testPinnedPurchaseBigAmount()
    }
    
    func testPinLessPurchase() throws {
        let purchase = PurchaseDetailModel(amount: 1000)
        let expectedUnpinCode = "*182*2*1*1*1*1000#"
        
        XCTAssertEqual(expectedUnpinCode, purchase.getFullUSSDCode(with: nil))
    }
    
    func testPinnedPurchaseSmallAmount() throws {
        let pin = makeCodePin(22000)
        let purchase = PurchaseDetailModel(amount: 100)
        
        let expectedPinnedCode = "*182*2*1*1*1*100*\(pin)#"
        XCTAssertEqual(expectedPinnedCode, purchase.getFullUSSDCode(with: pin))
    }
    
    func testPinnedPurchaseBigAmount() throws {
        let pin = try Dialer.CodePin(22000)
        let purchase = PurchaseDetailModel(amount: 1000)
        
        let expectedPinnedCode = "*182*2*1*1*1*1000#"
        XCTAssertEqual(expectedPinnedCode, purchase.getFullUSSDCode(with: .some(pin)))
    }
    
    private func makeCodePin(_ value: Int) -> CodePin {
        try! CodePin(value)
    }
    
}
