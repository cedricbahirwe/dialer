//
//  Views+Extension.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 06/06/2021.
//

import SwiftUI

struct MTNDisabling: ViewModifier {
    func body(content: Content) -> some View {
        content
            .disabled(CTCarrierDetector.shared.checkCellularProvider().status == false)
    }
}

extension View {
    
    /// Disable access if `Mtn` sim card is not detected
    /// - Returns: a disabled view if mtn card is not detected (no interaction).
    func momoDisability() -> some View {
        ModifiedContent(content: self, modifier: MTNDisabling())
    }
}
