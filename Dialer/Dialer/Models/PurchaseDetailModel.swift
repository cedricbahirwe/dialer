//
//  PurchaseDetailModel.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 04/01/2022.
//

import Foundation

struct PurchaseDetailModel: Hashable, Codable {
    private var prefixCode: String { "*18*2*2*1*1*1*" }
    var amount: Int = 0
    var type: CodeType = .momo
    var fullCode: String {
        "\(prefixCode)\(amount)*PIN#"
    }
    
    func getDialCode(pin: String) -> String {
        if pin.isEmpty {
            return "\(prefixCode)\(amount)#"
        } else {
            return "\(prefixCode)\(amount)*\(pin)#"
        }
    }
    static let example = PurchaseDetailModel()
    
    
    enum CodeType: String, Codable {
        case momo, call, message, other
    }
}
