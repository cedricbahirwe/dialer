//
//  Models.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 14/02/2021.
//

import Foundation

enum MomoOption: String {
    case payment
    case balance

    case airtime
}

struct Dial: Identifiable {
    var id = UUID()
    var title: String
    var subAction: [SubDial]?
}

struct SubDial: Identifiable {
    var id = UUID()
    var title: String
}

enum DialerOption {
    case internet
    case call
    case airtimeBalance
    case momo(option: MomoOption)
    
    var value: String {
        switch self {
        case .internet: return "*345*"
        case .airtimeBalance: return "*131#"
        case .call: return "*140*"
        case .momo(option: let option):
            switch option {
            case .airtime:
                return ""
            case .balance: return "*182*6*1*"
            case .payment:
                return "*182*"
            }
        }
    }
}
