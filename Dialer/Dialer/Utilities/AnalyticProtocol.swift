//
//  AnalyticProtocol.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 26/02/2023.
//

import Foundation

protocol AnalyticProtocol {
    func logEvent(_ name: String, meta: [String: AnyHashable])
    func logScreen(_ name: ScreenName, meta: [String: AnyHashable])

}
