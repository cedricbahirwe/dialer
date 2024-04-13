//
//  Views+Extension.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 06/06/2021.
//

import SwiftUI

extension View {
    
    /// Tracking screen appearance and disappearance
    func trackAppearance(_ screen: ScreenName) -> some View {
        self
            .onAppear { Tracker.shared.startSession(for: screen) }
            .onDisappear() { Tracker.shared.stopSession(for: screen) }
    }
    
    /// Handle Tap Gesture for Biometrics Evaluation
    func onTapForBiometrics(onEvaluation: @escaping(Bool) -> Void) -> some View {
        ModifiedContent(content: self, modifier: BiometricsAccessibility(onEvaluation: onEvaluation))
    }
    
    /// Dismiss keyboard
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    /// Neumorphic design used for input fields all over
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
