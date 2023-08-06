//
//  DialerUSSDCodeTests.swift
//  DialerTests
//
//  Created by Cédric Bahirwe on 11/12/2022.
//

import XCTest
@testable import Dialer

final class DialerUSSDCodeTests: XCTestCase {
    typealias USSDError = USSDCode.USSDCodeValidationError

    func testUSSDCodesSuit() throws {
        try testUniqueUSSCodes()
        try testUSSDCodesNulls()
        try testUSSDCodesValidationErrors()
    }

    func testUniqueUSSCodes() throws {
        let code1 = try USSDCode(id: UUID(), title: "Momo", ussd: "*182#")
        let code2 = try USSDCode(id: UUID(), title: "Airtime", ussd: "*131*1#")

        XCTAssertEqual(code1.title, "Momo")
        XCTAssertEqual(code1.ussd, "*182#")

        XCTAssertEqual(code2.title, "Airtime")
        XCTAssertEqual(code2.ussd, "*131*1#")

        XCTAssertNotEqual(code1, code2)
    }

    func testUSSDCodesNulls() throws {
        XCTAssertThrowsError(try USSDCode(id: UUID(), title: "Momo", ussd: "**182##"))
        XCTAssertThrowsError(try USSDCode(id: UUID(), title: "Momo", ussd: "*182##"))

        XCTAssertThrowsError(try USSDCode(id: UUID(), title: "Momo", ussd: ""))

        XCTAssertThrowsError(try USSDCode(id: UUID(), title: "", ussd: "*1212#"))
    }

    func testUSSDCodesValidationErrors() throws {
        XCTAssertThrowsError(try USSDCode(id: UUID(), title: "Momo", ussd: "")) { error in
            XCTAssertEqual(error as! USSDError, USSDError.emptyUSSD)
        }


        XCTAssertThrowsError(try USSDCode(id: UUID(), title: "", ussd: "")) { error in
            XCTAssertEqual(error as! USSDError, USSDError.emptyTitle)
        }

        XCTAssertThrowsError(try USSDCode(id: UUID(), title: "Momo", ussd: "9232")) { error in
            XCTAssertEqual(error as! USSDError, USSDError.invalidFirstCharacter)
        }

        XCTAssertThrowsError(try USSDCode(id: UUID(), title: "Momo", ussd: "*9232")) { error in
            XCTAssertEqual(error as! USSDError, USSDError.invalidLastCharacter)
        }

        XCTAssertThrowsError(try USSDCode(id: UUID(), title: "Momo", ussd: "*9s232#")) { error in
            XCTAssertEqual(error as! USSDError, USSDError.invalidUSSD)
        }
    }
}

