//
//  TimeInterval+Extensions.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 01/03/2023.
//

import Foundation

extension TimeInterval {
    func formattedString() -> String {
        let time = Int(self)

        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)

        var formatString = ""
        if hours == 0 {
            if (minutes < 10) {
                formatString = "%2d:%0.2d"
            }else {
                formatString = "%0.2d:%0.2d"
            }
            return String(format: formatString, minutes, seconds)
        } else {
            formatString = "%2d:%0.2d:%0.2d"
            return String(format: formatString, hours, minutes, seconds)
        }
    }
}
