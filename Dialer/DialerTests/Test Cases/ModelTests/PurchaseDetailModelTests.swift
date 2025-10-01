//
//  PurchaseDetailModelTests.swift
//  DialerTests
//
//  Created by Cédric Bahirwe on 07/03/2023.
//

import XCTest
@testable import Dialer

final class PurchaseDetailModelTests: XCTestCase {
    
    func testPinLessPurchase() throws {
        let purchase = AirtimeTransaction(amount: 1000)
        let expectedUnpinCode = "*182*2*1*1*1*1000#"
        
        XCTAssertEqual(expectedUnpinCode, purchase.fullUSSDCode)
    }
}
