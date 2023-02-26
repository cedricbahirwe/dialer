//
//  UserDefaults+Extension.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 16/08/2022.
//

import Foundation

typealias UserDefaultsKeys = UserDefaults.Keys
extension UserDefaults {

    /// Storing the used UserDefaults keys for safety.
    enum Keys {
        static let recentCodes = "recentCodes"
        static let pinCode = "pinCode"
        static let lastSyncDate = "lastSyncDate"

        // Onboarding
        static let showWelcomeView = "showWelcomeView"

        // Electricity
        static let meterNumbers = "meterNumbers"

        // Biometrics
        static let allowBiometrics = "allowBiometrics"

        // Review
        static let appStartUpsCountKey = "appStartUpsCountKey"
        static let lastVersionPromptedForReviewKey = "lastVersionPromptedForReviewKey"

        // Custom USSD codes
        static let customUSSDCodes = "customUSSDCodes"

        // Last Known user location
        static let lastUserLocation = "lastUserLocation"
    }
}
