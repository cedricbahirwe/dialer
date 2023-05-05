//
//  CamelToSnakeTests.swift
//  DialerTests
//
//  Created by Cédric Bahirwe on 05/05/2023.
//

import XCTest
@testable import Dialer

final class CamelToSnakeTests: XCTestCase {
    
    func testEmptyString() {
        let input = ""
        let expected = ""
        XCTAssertEqual(input.camelToSnake(), expected)
    }
    
    func testSingleWord() {
        let input = "hello"
        let expected = "hello"
        XCTAssertEqual(input.camelToSnake(), expected)
    }
    
    func testMultipleWords() {
        let input = "helloWorldHowAreYou"
        let expected = "hello_world_how_are_you"
        XCTAssertEqual(input.camelToSnake(), expected)
    }
    
    func testNumbers() {
        let input = "myVariableName123"
        let expected = "my_variable_name123"
        XCTAssertEqual(input.camelToSnake(), expected)
    }
    
    func testUppercase() {
        let input = "HELLO"
        let expected = "hello"
        XCTAssertEqual(input.camelToSnake(), expected)
    }
    
    func testMixedCase() {
        let input = "helloWorld_HowAreYou"
        let expected = "hello_world__how_are_you"
        XCTAssertEqual(input.camelToSnake(), expected)
    }
}
