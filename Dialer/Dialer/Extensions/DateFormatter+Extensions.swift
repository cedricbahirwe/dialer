//
//  DateFormatter+Extensions.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 01/03/2023.
//

import Foundation

extension DateFormatter {
    public convenience init(format: String, timeZone: TimeZone = .current, locale: String? = nil) {
        self.init()
        dateFormat = format
        self.timeZone = timeZone
        if let locale = locale {
            self.locale = Locale(identifier: locale)
        }
    }
}
