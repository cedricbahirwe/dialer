//
//  Binding+Extension.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 21/04/2022.
//

import SwiftUI

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
