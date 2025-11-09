//
//  TransactionModel.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 14/06/2021.
//

import Foundation
import DialerTO

struct Transaction: Identifiable, Codable {
    var id: String { Date().description }
    var amount: Int
    var number: String
    var type: TransactionType

    /// This flag indicates whether the transaction was optimized using `DialerTO`
    var isOptimized: Bool

    init(amount: Int, number: String, type: TransactionType, isOptimized: Bool) {
        self.amount = amount
        self.number = number
        self.type = type
        self.isOptimized = isOptimized
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        amount = try container.decode(Int.self, forKey: .amount)
        number = try container.decode(String.self, forKey: .number)
        type = try container.decode(TransactionType.self, forKey: .type)
        isOptimized = try container.decodeIfPresent(Bool.self, forKey: .isOptimized) ?? false
    }

    struct Model: Hashable, Dialable {
        var amount: String
        var number: String
        var type: TransactionType
        var isOptimized: Bool = false

        var doubleAmount: Double {
            Double(amount) ?? 0.0
        }

        var estimatedFee: Int? {
            if type == .client {
                return TransactionOptimizer.calculateFee(for: Int(doubleAmount))
            } else {
                return nil
            }
        }

        private var trailingCode: String {
            // Need strategy to deal with country code
            number.removingEmptySpaces + "*" + String(amount)
        }

        var fullUSSDCode: String {
            type == .client ? "*182*1*1*\(trailingCode)#" : "*182*8*1*\(trailingCode)#"
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

        func toParent() -> Transaction {
            Transaction(
                amount: Int(amount) ?? 0,
                number: number,
                type: type,
                isOptimized: isOptimized
            )
        }
    }

    enum TransactionType: String, CaseIterable, Codable, Sendable {
        case client, merchant

        mutating func toggle() {
            self = self == .client ? .merchant : .client
        }
    }
}
