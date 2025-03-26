//
//  TransactionModelTests.swift
//  DialerTests
//
//  Created by Cédric Bahirwe on 25/03/2025.
//  Copyright © 2025 Cédric Bahirwe. All rights reserved.
//

import XCTest
@testable import Dialer

final class TransactionModelTests: XCTestCase {

    // MARK: - Transaction Type Tests
    func testTransactionTypeToggle() {
        var clientType = Transaction.TransactionType.client
        clientType.toggle()
        XCTAssertEqual(clientType, .merchant, "Transaction type should toggle from client to merchant")

        clientType.toggle()
        XCTAssertEqual(clientType, .client, "Transaction type should toggle back to client")
    }

    // MARK: - Transaction Model Validation Tests
    func testClientTransactionValidation() {
        // Valid client transaction
        let validClientTransaction = Transaction.Model(
            amount: "1000",
            number: "0781234567",
            type: .client
        )
        XCTAssertTrue(validClientTransaction.isValid, "Valid client transaction should pass validation")

        // Invalid client transaction - zero amount
        let zeroAmountTransaction = Transaction.Model(
            amount: "0",
            number: "0781234567",
            type: .client
        )
        XCTAssertFalse(zeroAmountTransaction.isValid, "Transaction with zero amount should be invalid")

        // Invalid client transaction - short number
        let shortNumberTransaction = Transaction.Model(
            amount: "1000",
            number: "078123",
            type: .client
        )
        XCTAssertFalse(shortNumberTransaction.isValid, "Transaction with short number should be invalid")
    }

    func testMerchantTransactionValidation() {
        // Valid merchant transaction
        let validMerchantTransaction = Transaction.Model(
            amount: "5000",
            number: "1234567",
            type: .merchant
        )
        XCTAssertTrue(validMerchantTransaction.isValid, "Valid merchant transaction should pass validation")

        // Invalid merchant transaction - zero amount
        let zeroAmountTransaction = Transaction.Model(
            amount: "0",
            number: "1234567",
            type: .merchant
        )
        XCTAssertFalse(zeroAmountTransaction.isValid, "Merchant transaction with zero amount should be invalid")
    }

    // MARK: - Transaction Fee Calculation Tests
    func testTransactionFeeCalculation() {
        // Test different fee ranges
        let lowAmountTransaction = Transaction.Model(
            amount: "500",
            number: "0781234567",
            type: .client
        )
        XCTAssertEqual(lowAmountTransaction.estimatedFee, 20, "Fee for amount 500 should be 20")

        let midAmountTransaction = Transaction.Model(
            amount: "5000",
            number: "0781234567",
            type: .client
        )
        XCTAssertEqual(midAmountTransaction.estimatedFee, 100, "Fee for amount 5000 should be 100")

        let highAmountTransaction = Transaction.Model(
            amount: "100000",
            number: "0781234567",
            type: .client
        )
        XCTAssertEqual(highAmountTransaction.estimatedFee, 250, "Fee for amount 100000 should be 250")

        let merchantTransaction = Transaction.Model(
            amount: "5000",
            number: "1234567",
            type: .merchant
        )
        XCTAssertEqual(merchantTransaction.estimatedFee, 0, "Merchant transaction fee should always be 0")
    }

    // MARK: - Full Code Generation Tests
    func testFullCodeGeneration() {
        let clientTransaction = Transaction.Model(
            amount: "1000",
            number: "0781234567",
            type: .client
        )
        XCTAssertEqual(
            clientTransaction.fullCode,
            "*182*1*1*0781234567*1000#",
            "Client transaction full code should be correctly formatted"
        )

        let merchantTransaction = Transaction.Model(
            amount: "5000",
            number: "1234567",
            type: .merchant
        )
        XCTAssertEqual(
            merchantTransaction.fullCode,
            "*182*8*1*1234567*5000#",
            "Merchant transaction full code should be correctly formatted"
        )
    }

    // MARK: - Conversion Tests
    func testConversionMethods() {
        let transactionModel = Transaction.Model(
            amount: "1000",
            number: "0781234567",
            type: .client
        )

        // Test doubleAmount conversion
        XCTAssertEqual(transactionModel.doubleAmount, 1000.0, "Double amount should convert correctly")

        // Test toParent() method
        let parentTransaction = transactionModel.toParent()
        XCTAssertEqual(parentTransaction.amount, 1000, "Parent transaction amount should match")
        XCTAssertEqual(parentTransaction.number, "0781234567", "Parent transaction number should match")
        XCTAssertEqual(parentTransaction.type, .client, "Parent transaction type should match")
    }

    // MARK: - Edge Case Tests
    func testInvalidAmountConversion() {
        let invalidAmountTransaction = Transaction.Model(
            amount: "invalid",
            number: "0781234567",
            type: .client
        )

        XCTAssertEqual(invalidAmountTransaction.doubleAmount, 0.0, "Invalid amount should convert to 0.0")
        XCTAssertFalse(invalidAmountTransaction.isValid, "Invalid amount should result in invalid transaction")
    }
}
