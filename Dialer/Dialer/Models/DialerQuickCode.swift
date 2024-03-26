//
//  DialerQuickCode.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 16/08/2022.
//

import Foundation

enum DialerQuickCode {
    case mobileWalletBalance
    case electricity(meter: String, amount: Int)
    case other(String)

    var ussd: String {
        switch self {
        case .mobileWalletBalance:
            return "*182*6*1#"
        case .electricity(let meterNumber, let amount):
            return "*182*2*2*1*1*\(meterNumber)*\(amount)#"
        case .other(let fullCode):
            return fullCode
        }
    }
}
