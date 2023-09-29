//
//  AppReviewing.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 14/01/2022.
//

import StoreKit

enum ReviewHandler {
    
    static func requestReview() {
        var count = UserDefaults.standard.integer(forKey: UserDefaultsKeys.appStartUpsCountKey)
        count += 1
        UserDefaults.standard.set(count, forKey: UserDefaultsKeys.appStartUpsCountKey)
        
        let infoDictionaryKey = kCFBundleVersionKey as String
        guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String
            else { fatalError("Expected to find a bundle version in the info dictionary") }

        let lastVersionPromptedForReview = UserDefaults.standard.string(forKey: UserDefaultsKeys.lastVersionPromptedForReviewKey)
        
        if count%4==0 && currentVersion != lastVersionPromptedForReview {
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 1.0) {
                if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                    UserDefaults.standard.set(currentVersion, forKey: UserDefaultsKeys.lastVersionPromptedForReviewKey)
                }
            }
        }
    }
    
    static func requestReviewManually() {
        guard let writeReviewURL = URL(string: DialerlLinks.dialerAppReview)
        else { return }
        UIApplication.shared.open(writeReviewURL)
    }
}
