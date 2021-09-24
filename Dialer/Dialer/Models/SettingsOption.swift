//
//  SettingsOption.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 24/09/2021.
//

import SwiftUI

enum SettingsOption: Int {
    case deletePin
    case getStarted
    case contactUs
    case tweetUs
    case translationSuggestion
    case about
    case review
    
    func getItem() -> SettingsItem { SettingsOption.items[rawValue] }
    
    static var items: [SettingsItem] = [
        .init(sysIcon: "trash", color: .red, title: "Remove Momo Pin",
              subtitle: "You'll need to re-enter it later."),
        .init(sysIcon: "lightbulb.fill", color: .blue, title: "Just getting started?", subtitle: "Read our quick start blog post."),
        .init(sysIcon: "bubble.left.and.bubble.right.fill", color: .pink, title: "Contact Us", subtitle: "Get help or ask a question."),
        .init(icon: "twitter", color: Color("twitter"), title: "Tweet Us", subtitle: "Stay up to date."),
        .init(icon: "translation", color: .blue, title: "Translation Suggestion", subtitle: "Improve our localization."),
        .init(sysIcon: "info", color: .orange, title: "About", subtitle: "Version information."),
        .init(sysIcon: "heart.fill", color: .red, title: "Review Dialer", subtitle: "Let us know how we are doing.")
        ]
}
