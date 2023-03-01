//
//  Device+Extensions.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 01/03/2023.
//

import UIKit

extension UIDevice.BatteryState {
    var status: String {
        switch self {
        case .unplugged: return "unplugged"
        case .charging: return"charging"
        case .full: return "full"
        default: return "unknown"
        }
    }
}
