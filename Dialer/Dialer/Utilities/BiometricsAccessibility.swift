//
//  BiometricsAccessibility.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 13/04/2024.
//  Copyright © 2024 Cédric Bahirwe. All rights reserved.
//

import SwiftUI

struct BiometricsAccessibility: ViewModifier {
    var onEvaluation: (Bool) -> Void

    private let biometrics = BiometricsAuth.shared
    @AppStorage(UserDefaultsKeys.allowBiometrics)
    private var allowBiometrics = false
    
    func body(content: Content) -> some View {
        content
            .onTapGesture(perform: manageBiometrics)
    }
    
    private func manageBiometrics() {
        if allowBiometrics {
            Task { @MainActor in
                let state = await biometrics.onStateChanged()
                onEvaluation(state)
            }
        } else {
            onEvaluation(true)
        }
    }
}
