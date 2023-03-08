//
//  PurchaseDetailModel.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 04/01/2022.
//

import Foundation

struct PurchaseDetailModel: Hashable, Codable {
    var prefixCode: String { "*182*2*2*1*1*1*" }

    var amount: Int = 0
    var fullCode: String {
        "\(prefixCode)\(amount)*PIN#"
    }
    
    func getDialCode(pin: String? = nil) -> String {
        if let pin, !pin.isEmpty {
            return "\(prefixCode)\(amount)*\(pin)#"
        } else {
            return "\(prefixCode)\(amount)#"
        }
    }
    static let example = PurchaseDetailModel()
}

enum USSD {
    static let momo = "*182*"
}
