//
//  DialerQuickCode.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 16/08/2022.
//

import Foundation

enum DialerQuickCode {
    case internetBalance, airtimeBalance
    case voicePackBalance, mobileNumber
    case mobileWalletBalance(code: Int?)
    case electricity(meter: String, amount: Int, code: Int?)
    case other(String)

    var ussd: String {
        switch self {
        case .internetBalance: return "*345*5#"
        case .airtimeBalance: return "*131#"
        case .voicePackBalance: return "*140*5#"
        case .mobileNumber: return "*135*8#"
        case .mobileWalletBalance(let code):
            return "*182*6*1\(codeSuffix(code))"
        case .electricity(let meterNumber, let amount, let code):
            return "*182*2*2*1*1*\(meterNumber)*\(amount)\(codeSuffix(code))"
        case .other(let fullCode):
            return fullCode
        }
    }

    private func codeSuffix(_ code: Int?) -> String {
        return code == nil ? "#" : "*\(code!)#"
    }

}
