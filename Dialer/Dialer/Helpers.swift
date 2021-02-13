//
//  Helpers.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 08/02/2021.
//

import Foundation
import SwiftUI

extension View {
    func resignKeyboardOnDragGesture() -> some View {
        return modifier(ResignKeyboardOnDragGesture())
    }
}
extension UIApplication {
    func endEditing(_ force: Bool) {
        windows
            .filter{$0.isKeyWindow}
            .first?
            .endEditing(force)
    }
    
}

struct ResignKeyboardOnDragGesture: ViewModifier {
    var gesture = DragGesture().onChanged{_ in
        UIApplication.shared.endEditing(true)
    }
    func body(content: Content) -> some View {
        content.gesture(gesture)
    }
}

