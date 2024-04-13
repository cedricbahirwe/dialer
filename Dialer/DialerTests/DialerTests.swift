//
//  DialerTests.swift
//  DialerTests
//
//  Created by Cédric Bahirwe on 09/08/2021.
//

import XCTest
@testable import Dialer

class DialerTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testAppPerformance() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testMtnNumbers() throws {
        XCTAssert("0782628511".isMtnNumber, "This is not an mtn number")
        
        XCTAssert("0790188096".isMtnNumber, "This is not an mtn number")
        
        XCTAssert("250782628511".isMtnNumber, "This is not an mtn number")
        
        XCTAssert("+250782628511".isMtnNumber, "This is not an mtn number")
        
        XCTAssertFalse("782628511".isMtnNumber, "This is not an mtn number")
        
        XCTAssertFalse("25072628511".isMtnNumber, "This is not an mtn number")
        
        XCTAssert("250792628511".isMtnNumber, "This is not an mtn number")
        
        XCTAssertEqual("0782628511", "250782628511".asMtnNumber())
        
        XCTAssertEqual("0782628511", "+250782628511".asMtnNumber())
        
        XCTAssertNotEqual("250782628511", "250782628511".asMtnNumber())
    }
}
