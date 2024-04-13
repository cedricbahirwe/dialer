//
//  DialerQuickCode.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 16/08/2022.
//

import Foundation

#warning("Need to rethink this")
enum DialerQuickCode {
    case other(String)

    var ussd: String {
        switch self {
        case .other(let fullCode):
            return fullCode
        }
    }
}
