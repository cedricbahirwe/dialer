//
//  Views+Extension.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 06/06/2021.
//

import SwiftUI

struct BiometricsAccessibility: ViewModifier {
    private let biometrics = BiometricsAuth.shared
    var onEvaluation: (Bool) -> Void
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

extension Bool {
    static var isIOS16AndPlus: Bool {
        guard #available(iOS 16.0.0, *) else { return false }
        return true
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
    
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: @autoclosure () -> Bool, transform: (Self) -> Content) -> some View {
        if condition() {
            transform(self)
        } else {
            self
        }
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
