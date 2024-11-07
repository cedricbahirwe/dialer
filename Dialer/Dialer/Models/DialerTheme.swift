//
//  DialerTheme.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 07/11/2024.
//  Copyright © 2024 Cédric Bahirwe. All rights reserved.
//

import Foundation
import SwiftUICore

enum DialerTheme: String, Codable, CaseIterable {
    case system, light, dark

    var rawCapitalized: String { rawValue.capitalized }

    func getIconSystemName() -> String {
        switch self {
        case .system: "gear"
        case .light: "sun.max"
        case .dark: "moon.fill"
        }
    }

    var asColorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}
