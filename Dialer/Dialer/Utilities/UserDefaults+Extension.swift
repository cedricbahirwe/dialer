//
//  UserDefaults+Extension.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 16/08/2022.
//

import Foundation

enum UserDefaultsKeys {
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
    
    // Last Date the app asked the user to update
    static let lastAskedDateToUpdate = "lastAskedDateToUpdate"
    
    static let deviceAccount = "deviceAccount"
    
    // Daily local notification scheduled
    static let dailyNotificationEnabled = "dailyNotificationEnabled"
}

