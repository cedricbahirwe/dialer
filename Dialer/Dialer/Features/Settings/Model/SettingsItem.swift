//
//  SettingsItem.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 24/09/2021.
//

import SwiftUI

struct SettingsItem: Identifiable {
    init(icon: String, color: Color, title: LocalizedStringKey, subtitle: LocalizedStringKey) {
        self.icon = Image(icon)
        self.color = color
        self.title = title
        self.subtitle = subtitle
    }
    
    init(sysIcon: String, color: Color, title: LocalizedStringKey, subtitle: LocalizedStringKey) {
        self.icon = Image(systemName: sysIcon)
        self.color = color
        self.title = title
        self.subtitle = subtitle
    }
    
    let id = UUID()
    let icon: Image
    let color: Color
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
}
