//
//  TransactionModel.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 14/06/2021.
//

import Foundation

struct Transaction: Identifiable, Codable {
    var id: String { Date().description }
    var amount: Int
    var number: String
    var type: TransactionType

    struct Model {
        var amount: String
        var number: String
        var type: TransactionType

        var doubleAmount: Double {
            Double(amount) ?? 0.0
        }

        var estimatedFee: Int {
            if type == .client {
                for range in Self.transactionFees {
                    if range.key.contains(Int(doubleAmount)) {
                        return range.value
                    }
                }
                return -1
            } else {
                return 0
            }
        }

        private var trailingCode: String {
            // Need strategy to deal with country code
            number.removingEmptySpaces + "*" + String(amount)
        }

        var fullCode: String {
            if type == .client {
                return "*182*1*1*\(trailingCode)#"
            } else {
                return "*182*8*1*\(trailingCode)#"
            }
        }

        /// Determines whether a transaction is valid
        /// Need better operation to handle edge cases (long/short numbers)
        var isValid: Bool {
            switch type {
            case .client:
                return doubleAmount > 0 && number.count >= 8
            case .merchant:
                // TODO: Needs a firebase remote config to set the merchant digits count
                return doubleAmount > 0 && (AppConstants.merchantDigitsRange).contains(number.count)
            }
        }

        var cleaned: Transaction {
            Transaction(
                amount: Int(amount) ?? 0,
                number: number,
                type: type
            )
        }

        static let transactionFees = [0...1_000 : 20, 1_001...10_000 : 100, 10_001...150_000 : 250, 150_001...2_000_000 : 15_00]

        func toParent() -> Transaction {
            Transaction(amount: Int(doubleAmount), number: number, type: type)
        }
    }

    enum TransactionType: String, CaseIterable, Codable, Sendable {
        case client, merchant

        mutating func toggle() {
            self = self == .client ? .merchant : .client
        }
    }
}
