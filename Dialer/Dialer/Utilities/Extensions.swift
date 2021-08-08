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
        // Check for the validity of the mtn number (078 && 079)
        return
            trimmingCharacters(in: .whitespaces).hasPrefix("+25078") ||
        trimmingCharacters(in: .whitespaces).hasPrefix("25078") ||
        trimmingCharacters(in: .whitespaces).hasPrefix("078") ||
        trimmingCharacters(in: .whitespaces).hasPrefix("+25079") ||
        trimmingCharacters(in: .whitespaces).hasPrefix("25079") ||
        trimmingCharacters(in: .whitespaces).hasPrefix("079")
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


extension Binding {
    public func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { wrappedValue },
            set: { newValue in
                wrappedValue = newValue
                handler(newValue )
            }
        )
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
