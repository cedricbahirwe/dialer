//
//  String+Extension.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 21/04/2022.
//

import Foundation
import SwiftUI

public extension String {
    /// Check for the validity of the `MTN` number (078 && 079)
    /// This is a agnostic approach, since it does not handle all the edge cases
    var isMtnNumber: Bool {
        var number = trimmingCharacters(in: .whitespacesAndNewlines)
        number = number.replacingOccurrences(of: " ", with: "")
        return number.hasPrefix("+25078") || number.hasPrefix("25078") || number.hasPrefix("078") ||
        number.hasPrefix("+25079") || number.hasPrefix("25079") || number.hasPrefix("079")
    }

    /// Removes the `Rwanda` country code and return a pure  `MTN` number format
    func asMtnNumber() -> String {
        var mtnNumber = self
        if mtnNumber.hasPrefix("25") {
            mtnNumber.removeFirst(2)
        } else if mtnNumber.hasPrefix("+25") {
            mtnNumber.removeFirst(3)
        }
        return mtnNumber
    }

}
