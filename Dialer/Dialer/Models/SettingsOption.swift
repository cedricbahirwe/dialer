//
//  SettingsOption.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 24/09/2021.
//

import SwiftUI

enum SettingsOption: Int {
    case changeLanguage
    case biometrics
    case deletePin
    case getStarted
    case contactUs
    case tweetUs
    case translationSuggestion
    case about
    case review
        
    func getSettingsItem() -> SettingsItem {
        switch self {
        case .changeLanguage:
            return .init(icon: "language", color: .main.opacity(0.7), title: "Change Language", subtitle: "Select your desired language.")
        case .biometrics:
            return .init(sysIcon: "lock.fill", color: .green, title: "Biometrics", subtitle: "Choose your own biometric authentication.")
        case .deletePin:
            return .init(sysIcon: "trash", color: .red, title: "Remove Pin", subtitle: "You'll need to re-enter it later.")
        case .getStarted:
            return .init(sysIcon: "lightbulb.fill", color: .blue, title: "Just getting started?", subtitle: "Read our quick start blog post.")
        case .contactUs:
            return .init(sysIcon: "bubble.left.and.bubble.right.fill", color: .pink, title: "Contact Us", subtitle: "Get help or ask a question.")
        case .tweetUs:
            return .init(icon: "twitter", color: Color("twitter"), title: "Tweet Us", subtitle: "Stay up to date.")
        case .translationSuggestion:
            return .init(icon: "translation", color: .blue, title: "Translation Suggestion", subtitle: "Improve our localization.")
        case .about:
            return .init(sysIcon: "info", color: .orange, title: "About", subtitle: "Version information.")
        case .review:
            return .init(sysIcon: "heart.fill", color: .red, title: "Review Dialer", subtitle: "Let us know how we are doing.")
        }
    }
}
