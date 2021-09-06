//
//  PrimitiveExtensions.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 09/08/2021.
//

import Foundation
import SwiftUI

extension String {
    
    /// Check for the validity of the `MTN` number (078 && 079)
    /// This is a agnostic approach, since it does not handle all the edge cases
    public var isMtnNumber: Bool {
        
        return
            trimmingCharacters(in: .whitespaces).hasPrefix("+25078") ||
        trimmingCharacters(in: .whitespaces).hasPrefix("25078") ||
        trimmingCharacters(in: .whitespaces).hasPrefix("078") ||
        trimmingCharacters(in: .whitespaces).hasPrefix("+25079") ||
        trimmingCharacters(in: .whitespaces).hasPrefix("25079") ||
        trimmingCharacters(in: .whitespaces).hasPrefix("079")
    }
    
    
    /// Removes the `Rwanda` country code and return a pure  `MTN` number format
    public func asMtnNumber() -> String {
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
