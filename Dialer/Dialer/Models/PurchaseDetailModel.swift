//
//  PurchaseDetailModel.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 04/01/2022.
//

import Foundation

struct PurchaseDetailModel: Hashable, Codable {
    var amount: Int = 0
    var purchaseDate: Date = .now
    var fullCode: String { "\(prefixCode)\(amount)*PIN#" }
    
    private var prefixCode: String { "*182*2*1*1*1*" }

    func getDialCode(pin: String) -> String {
        /// `27/03/2023`: MTN disabled the ability to dial airtime USSD that includes Momo PIN for an amount greater than 99.
        /// You can dial the code with PIN for amount in the range of 10 to 99
        if AppConstants.allowedAmountRangeForPin.contains(amount) && !pin.isEmpty {
            return "\(prefixCode)\(amount)*\(pin)#"
        } else {
            return "\(prefixCode)\(amount)#"
        }
    }
}
