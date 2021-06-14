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
    var phoneNumber: String
    var type: Transactiontype
    var date: Date { Date() }
    
    var trailingCode: String {
        // Need strategy to deal with country code
        phoneNumber.replacingOccurrences(of: " ", with: "") + "*" + String(amount)
    }
    
    var fullCode: String {
        if type == .client {
            return "*182*1*1*\(trailingCode)#"
        } else {
            return "*182*8*1*\(trailingCode)#"
        }
    }
}
