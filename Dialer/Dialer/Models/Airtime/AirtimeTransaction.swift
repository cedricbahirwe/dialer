//
//  PurchaseDetailModel.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 04/01/2022.
//

import Foundation

struct AirtimeTransaction: Hashable, Codable {
    var amount: Int = 0
    var purchaseDate: Date = .now

    private var prefixCode: String { "*182*2*1*1*1*" }
}

extension AirtimeTransaction {
    func getFullUSSDCode() -> String {
        return "\(prefixCode)\(amount)#"
    }

    func getUSSDURL() throws -> URL {
        let fullCode = getFullUSSDCode()
        if let telUrl = URL(string: "tel://\(fullCode)") {
            return telUrl
        } else {
            throw DialingError.canNotDial
        }
    }
}
