//
//  PurchaseDetailModel.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 04/01/2022.
//

import Foundation

struct PurchaseDetailModel: Hashable, Codable {
    var amount: Int = 0
    var type: CodeType = .momo
    var fullCode: String {
        "*182*2*1*1*1*\(amount)*PIN#"
    }
    
    func getDialCode(pin: String) -> String {
        if pin.isEmpty {
            return "*182*2*1*1*1*\(amount)#"
        } else {
            return "*182*2*1*1*1*\(amount)*\(pin)#"
        }
    }
    static let example = PurchaseDetailModel()
    
    
    enum CodeType: String, Codable {
        case momo, call, message, other
    }
}
