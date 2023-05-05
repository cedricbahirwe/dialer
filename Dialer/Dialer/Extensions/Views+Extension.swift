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
            .disabled(CTCarrierDetector.shared.cellularProvider().status == false)
    }
}

struct BiometricsAccessibility: ViewModifier {
    private let biometrics = BiometricsAuth.shared
    var onEvaluation: (Bool) -> Void
    @AppStorage(UserDefaults.Keys.allowBiometrics)
    private var allowBiometrics = false
    
    func body(content: Content) -> some View {
        content
            .onTapGesture(perform: manageBiometrics)
    }
    
    private func manageBiometrics() {
        if allowBiometrics {
            biometrics.onStateChanged(onEvaluation)
        } else {
            onEvaluation(true)
        }
    }
}

extension View {
    /// Tracking screen appearance and disappearance
    func trackAppearance(_ screen: ScreenName) -> some View {
        self
            .onAppear { Tracker.shared.startSession(for: screen) }
            .onDisappear() { Tracker.shared.stopSession(for: screen) }
    }
    
    /// Handle  Tap Gesture for Biometrics Evaluation
    func onTapForBiometrics(onEvaluation: @escaping(Bool) -> Void) -> some View {
        ModifiedContent(content: self, modifier: BiometricsAccessibility(onEvaluation: onEvaluation))
    }
    
    /// Disable access if `Mtn` sim card is not detected
    /// - Returns: a disabled view if mtn card is not detected (no interaction).
    func momoDisability() -> some View {
        ModifiedContent(content: self, modifier: MTNDisabling())
    }
    
    /// Dismiss keyboard
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func withNeumorphStyle() -> some View {
        self
            .overlay(
                Rectangle()
                    .stroke(Color.darkShadow, lineWidth: 4)
                    .rotation3DEffect(.degrees(3), axis: (-0.05,0,0), anchor: .bottom)
                    .offset(x: 2, y: 2)
                    .clipped()
            )
            .overlay(
                Rectangle()
                    .stroke(Color.lightShadow, lineWidth: 4)
                    .rotation3DEffect(.degrees(3), axis: (-0.05,0,0), anchor: .bottom)
                    .offset(x: -2, y: -2)
                    .clipped()
            )
    }
}


extension List {
    @ViewBuilder
    func hideListBackground() -> some View {
        if #available(iOS 16.0, *) {
            self.scrollContentBackground(.hidden)
        } else {
            self
        }
    }
}
