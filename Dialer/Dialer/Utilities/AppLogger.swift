//
//  AppLogger.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 26/02/2023.
//

import Foundation
import os.log

class AppLogger: AnalyticProtocol {
    private let logger = OSLog(subsystem: "com.abc.incs.cedricbahirwe.Dialit", category: "AppLogger")

    func logEvent(_ name: String, meta: [String : AnyHashable]) {
        os_log("%@", log: logger, type: .debug, name)
    }

    func logScreen(_ name: ScreenName, meta: [String : AnyHashable]) {
        os_log("%@", log: logger, type: .debug, name.rawValue)
    }
}
