//
//  SettingsOption.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 24/09/2021.
//

import SwiftUI

enum SettingsOption {
    case biometrics
    case getStarted
    case contactUs
    case tweetUs
    case about
    case review
    case deleteUSSDs
    
    func getSettingsItem() -> SettingsItem {
        switch self {
        case .biometrics:
            return .init(sysIcon: "lock.fill", color: .green, title: "Biometric Authentication", subtitle: "For securing your activities on the app.")
        case .deleteUSSDs:
            return .init(sysIcon: "xmark.bin.fill", color: .red.opacity(0.9), title: "Delete All USSD codes", subtitle: "This action can not be undone.")
        case .getStarted:
            return .init(sysIcon: "lightbulb.fill", color: .blue, title: "Just getting started?", subtitle: "Read our quick start blog post.")
        case .contactUs:
            return .init(sysIcon: "bubble.left.and.bubble.right.fill", color: .pink, title: "Contact Us", subtitle: "Get help or ask a question.")
        case .tweetUs:
            return .init(icon: "twitter", color: Color("twitter"), title: "Tweet Us", subtitle: "Stay up to date.")
        case .about:
            return .init(sysIcon: "info", color: .orange, title: "About", subtitle: "Version information.")
        case .review:
            return .init(sysIcon: "heart.fill", color: .red, title: "Review Dialer", subtitle: "Let us know how we are doing.")
        }
    }
}
