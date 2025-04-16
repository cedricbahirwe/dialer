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

        let element = app.buttons

        debugMe(element)

        try testHomeMenuItemsDisplay()

    }
    
    func testTransferViewMerchantState() throws {
        
        app.staticTexts["Transfer/Pay"].tap()
        
        let dialButton = app.buttons["Dial USSD"]
        
        XCTAssertFalse(dialButton.isEnabled, "The dial button should be disabled at first")
        
        let amountField = app.textFields["transferAmountField"]
        amountField.tap()
        amountField.typeText("100")
        
        let numberField = app.textFields["transferNumberField"]
        numberField.tap()
        numberField.typeText("025809")
        
        XCTAssertTrue(dialButton.isEnabled, "The dial button should be enabled")
    }
    
    func testTransferViewClientState() throws {
        
        app.staticTexts["Transfer/Pay"].tap()
        
        let dialButton = app.buttons["Dial USSD"]
        
        XCTAssertFalse(dialButton.isEnabled, "The dial button should be disabled at first")
        
        let amountField = app.textFields["transferAmountField"]
        amountField.tap()
        amountField.typeText("1000")
        
        let switchButton = app.buttons["Send Money"]
        switchButton.tap()
        
        let numberField = app.textFields["transferNumberField"]
        numberField.tap()
        numberField.typeText("025809")
        
        XCTAssertFalse(dialButton.isEnabled, "The dial button should still be disabled")
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: (numberField.value as! String).count)
        
        numberField.typeText(deleteString)
        numberField.typeText("0782628511")
        
        XCTAssertTrue(dialButton.isEnabled, "The dial button should be enabled")
    }

    func testHomeMenuItemsDisplay() throws {
        XCTAssertTrue(app.staticTexts["Buy airtime"].exists)
        XCTAssertTrue(app.staticTexts["Transfer/Pay"].exists)
        XCTAssertTrue(app.staticTexts["Insights"].exists)
        XCTAssertTrue(app.staticTexts["My Space"].exists)
    }

    private func debugMe(_ element: XCUIElementQuery) {
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
