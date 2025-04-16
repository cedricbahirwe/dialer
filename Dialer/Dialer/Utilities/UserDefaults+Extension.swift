//
//  UserDefaults+Extension.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 16/08/2022.
//

import Foundation

typealias LocalKeys = UserDefaultsKeys
enum UserDefaultsKeys {
    static let appUniqueID = "appUniqueIdentifier"
    
    // Onboarding
    static let shouldShowWelcome = "showWelcomeView2"

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
    
    // Manually switch Dialer Theme
    static let appTheme = "appTheme"

    // Should show Username onboarding UI
    static let showUsernameSheet = "showUsernameSheet"

    // Apple Sign In Info
    static let appleSignInInfo = "appleSignInInfo"

    // Dialer Splits
    static let isDialerSplitsEnabled = "isDialerSplitsEnabled"

    // Donation Tip Display tracker
    static let didTransferMoneyCount = "didTransferMoneyCount"
}
