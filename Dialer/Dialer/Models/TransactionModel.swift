//
//  TransactionModel.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 14/06/2021.
//

import Foundation


enum Transactiontype {
    case client, merchant
    
    mutating func toggle() {
        self = self == .client ? .merchant : .client
    }
}

struct Transaction: Identifiable {
    let id = UUID()
    var amount: String
    var number: String
    var type: Transactiontype
    var date: Date { Date() }
    
    var trailingCode: String {
        // Need strategy to deal with country code
        number.replacingOccurrences(of: " ", with: "") + "*" + amount
    }
    
    
    var doubleAmount: Double {
        Double(amount) ?? 0
    }
    var fullCode: String {
        if type == .client {
            return "*182*1*1*\(trailingCode)#"
        } else {
            return "*182*8*1*\(trailingCode)#"
        }
    }
    
    
    /// Determines whether a transaction is valid
    /// Need better operation to handle edge cases (long/short  numbers)
    var isValid: Bool {
        switch type {
        case .client:
            return doubleAmount > 0 && number.count >= 8
        case .merchant:
            return doubleAmount > 0 && (5...6).contains(number.count)
        }
    }
}
