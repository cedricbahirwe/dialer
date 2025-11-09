//
//  AirtimeTransaction.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 04/01/2022.
//

import Foundation

struct AirtimeTransaction: Hashable, Codable {
    var amount: Int = 0
    var purchaseDate: Date = .now
}


extension AirtimeTransaction: Dialable {
    var isValid: Bool {
        amount >= AppConstants.minAmount
    }

    var fullUSSDCode: String {
        "\(AppConstants.airtimeUSSDPrefix)\(amount)#"
    }
}
