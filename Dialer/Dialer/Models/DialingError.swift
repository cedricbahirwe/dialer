//
//  DialingError.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 15/07/2023.
//

import Foundation

// MARK: - Error Models
enum DialingError: Error {
    case canNotDial, emptyPin, unknownFormat(String), invalidUSSD
    var message: String {
        switch self {
        case .canNotDial:
            return "Can not dial this code"
        case .unknownFormat(let format):
            return "Can not decode this format: \(format)"
        case .emptyPin:
            return "Pin Code not found, configure pin and try again"
        case .invalidUSSD:
            return "USSD code is invalid"
        }
    }
}
