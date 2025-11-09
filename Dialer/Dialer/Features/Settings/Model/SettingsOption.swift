//
//  SettingsOption.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 24/09/2021.
//

import SwiftUI

enum SettingsOption {
    case dialerSplits
    case biometrics
    case contactUs
    case socialX
    case about
    case review
    case deleteUSSDs
    case supportUs
    case appearance(currentTheme: DialerTheme)
    case deleteAccount

    func getSettingsItem() -> SettingsItem {
        switch self {
        case .appearance(let currentTheme):
               return .init(
                    sysIcon: {
                        if #available(iOS 17, *) {
                            "circle.lefthalf.filled.inverse"
                        } else {
                            "moon.circle.fill"
                        }
                    }(),
                    color: .green,
                    title: "Appearance",
                    subtitle: "Current: **\((currentTheme).rawCapitalized)**")
        case .supportUs:
            return .init(
                sysIcon: "gift.fill",
                color: .yellow,
                title: "Support us",
                subtitle: "Support continued updates and new features."
            )
        case .dialerSplits:
            return .init(
                sysIcon: AppConstants.dialerSplitsIconName,
                color: .mainRed,
                title: "Dialer Splits",
                subtitle: "Save on fees with smart payment splits."
            )
        case .biometrics:
            return .init(sysIcon: "lock.fill", color: .accent, title: "Biometric Authentication", subtitle: "For securing your activities on the app.")
        case .deleteUSSDs:
            return .init(sysIcon: "trash", color: .red, title: "Delete all USSD codes", subtitle: "This action can not be undone.")
        case .deleteAccount:
            return .init(sysIcon: "trash", color: .red, title: "Delete all my information", subtitle: "This action cannot be undone")
        case .contactUs:
            return .init(sysIcon: "bubble.left.and.bubble.right.fill", color: .pink, title: "Contact us", subtitle: "Get help or ask a question.")
        case .socialX:
            return .init(icon: "xsocial", color: .black, title: "Find us on X", subtitle: "Stay up to date.")
        case .about:
            return .init(sysIcon: "info", color: .orange, title: "About", subtitle: "Version information.")
        case .review:
            return .init(sysIcon: "heart.fill", color: .red, title: "Review Dialer", subtitle: "Let us know how we are doing.")
        }
    }
}
