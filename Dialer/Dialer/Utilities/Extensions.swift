//
//  Extensions.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 10/06/2021.
//

import Foundation
import SwiftUI

extension String {
    var isMtnNumber: Bool {
        return
            self.trimmingCharacters(in: .whitespaces).hasPrefix("+25078") ||
                self.trimmingCharacters(in: .whitespaces).hasPrefix("25078") ||
                self.trimmingCharacters(in: .whitespaces).hasPrefix("078") ||
                self.hasPrefix("")
    }
}

extension Array where Element == String  {
    var firstElement: String {
        get { return self.first ?? "" }
        set(value) {
            if isEmpty {
               self = []
            } else {
                self[0] = value
            }
            
        }
    }
}


// Dismiss keyboard
#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
