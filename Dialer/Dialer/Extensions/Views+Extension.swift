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
#if DEBUG
struct LanguagePreview: ViewModifier {
    init(_ language: LanguagePreview.Language) {
        self.language = language
    }

    let language: Language
    enum Language: String {
        case en, fr, kin
    }
    func body(content: Content) -> some View {
        content
            .environment(\.locale, .init(identifier: language.rawValue))
    }
}
#endif

extension View {
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

    /// Preview UI in supported languages in debug mode
    #if DEBUG
    func previewIn(_ language: LanguagePreview.Language) -> some View {
        ModifiedContent(content: self, modifier: LanguagePreview(language))
    }
    #endif
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
