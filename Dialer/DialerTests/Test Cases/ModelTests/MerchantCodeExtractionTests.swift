//
//  MerchantCodeExtractionTests.swift
//  DialerTests
//
//  Created by Cédric Bahirwe on 14/07/2023.
//

import XCTest
@testable import Dialer

final class MerchantCodeExtractionTests: XCTestCase {
    
    func testExtractMerchantCode() {
        let urlString = "tel://*182*8*1*025394%23"
        let expectedMerchantCode = "025394"
        
        let extractedMerchantCode = extractMerchantCode(from: urlString)
        
        XCTAssertEqual(extractedMerchantCode, expectedMerchantCode, "Merchant code extraction failed")
    }
    
    func testExtractMerchantCodeInvalidURL() {
        let urlString = "tel://1234567890"
        
        let extractedMerchantCode = extractMerchantCode(from: urlString)
        
        XCTAssertNil(extractedMerchantCode, "Merchant code extraction should be nil for invalid URL")
    }
    
    func testExtractMerchantCodeNoTrailingCharacter() {
        let urlString = "tel://*182*8*1*025394"
        let expectedMerchantCode = "025394"

        let extractedMerchantCode = extractMerchantCode(from: urlString)

        XCTAssertEqual(extractedMerchantCode, expectedMerchantCode, "Merchant code extraction failed when there is no trailing character")
    }

    func testExtractMerchantCodeInvalidPrefix() {
        let urlString = "tel://*182*8*2*025394%23"

        let extractedMerchantCode = extractMerchantCode(from: urlString)

        XCTAssertNil(extractedMerchantCode, "Merchant code extraction should be nil for invalid prefix")
    }

    
    private func extractMerchantCode(from code: String) -> String? {
        Merchant.extractMerchantCode(from: code)
    }

}
