//
//  DialerUITests.swift
//  DialerUITests
//
//  Created by Cédric Bahirwe on 04/08/2022.
//

import XCTest

class DialerUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func setUp() {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        self.app = app
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testHomeComponentDisplay() throws {
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        let element = app.buttons

        debugMe(element)

        try testHomeMenuItemsDisplay()

        try testDialButtonDisplay()

        try testNewDialViewComponents()

    }

    func testHomeMenuItemsDisplay() throws {
        XCTAssertTrue(app.staticTexts["Buy airtime"].exists)
        XCTAssertTrue(app.staticTexts["Transfer/Pay"].exists)
        XCTAssertTrue(app.staticTexts["History"].exists)
    }

    func testNewDialViewComponents() throws {
        app.buttons["Dial"].tap()
        // Delete button is hidden on first view appearance
        XCTAssertFalse(app.buttons["Backspace"].isEnabled)
    }

    func testDialButtonDisplay() throws {
        XCTAssertTrue(app.staticTexts["Dial"].exists)
        XCTAssertTrue(app.buttons["Dial"].exists)
    }

    private func debugMe(_ element: XCUIElementQuery) {
        print("Here is:", element.debugDescription, "***")
    }

//    func testLaunchPerformance() throws {
//        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
//            // This measures how long it takes to launch your application.
//            measure(metrics: [XCTApplicationLaunchMetric()]) {
//                XCUIApplication().launch()
//            }
//        }
//    }
}
