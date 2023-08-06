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

        let extractedMerchantCode = extractMerchantCode(from: urlString)

        XCTAssertNil(extractedMerchantCode, "Merchant code extraction failed when there is no trailing character")
    }

    func testExtractMerchantsDigits() {
        // Test cases: Input strings and their expected outputs
        let testCases: [(input: String, expectedOutput: String?)] = [
            ("tel://*182*8*1*029813%23", "029813"),
            ("tel:*182*8*1*029813%23", "029813"),
            ("tel://*182*8*1*912345%23", "912345"),
            ("tel:*182*8*1*912345%23", "912345"),
            ("tel://*182*8*1*000000%23", "000000"),
            ("tel:*182*8*1*000000%23", "000000"),
            ("tel://*182*8*1*123456%23", "123456"),
            ("tel:*182*8*1*123456%23", "123456"),
            ("tel://*182*8*1*999999%23", "999999"),
            ("tel:*182*8*1*999999%23", "999999"),
        ]
        
        for (index, testCase) in testCases.enumerated() {
            if let result = Merchant.extractMerchantCode(from: testCase.input) {
                XCTAssertEqual(result, testCase.expectedOutput, "Test case \(index + 1) failed. Expected: \(testCase.expectedOutput ?? "nil"), Got: \(result)")
            } else {
                XCTFail("Test case \(index + 1) failed. No match found.")
            }
        }
    }
    
    private func extractMerchantCode(from code: String) -> String? {
        Merchant.extractMerchantCode(from: code)
    }

}
