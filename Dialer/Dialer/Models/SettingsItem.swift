//
//  SettingsItem.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 24/09/2021.
//

import SwiftUI

public struct SettingsItem: Identifiable {
    public init(icon: String, color: Color, title: LocalizedStringKey, subtitle: LocalizedStringKey) {
        self.icon = Image(icon)
        self.color = color
        self.title = title
        self.subtitle = subtitle
    }
    
    public init(sysIcon: String, color: Color, title: LocalizedStringKey, subtitle: LocalizedStringKey) {
        self.icon = Image(systemName: sysIcon)
        self.color = color
        self.title = title
        self.subtitle = subtitle
    }
    
    public let id = UUID()
    public let icon: Image
    public let color: Color
    public let title: LocalizedStringKey
    public let subtitle: LocalizedStringKey
}
