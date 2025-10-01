//
//  AppConstants.swift
//  Dialer
//
//  Created by Nicolas Nshuti on 17/07/2023.
//

import Foundation

struct AppConstants {

    private init() { }

    static let minAmount = 1
    static let merchantDigitsRange = 5...7
    static let merchantMaxDigits = merchantDigitsRange.upperBound
    static let airtimeUSSDPrefix: String = "*182*2*1*1*1*"


    static let dialerSplitsIconName: String = {
        if #available(iOS 16.0, *), !ProcessInfo.processInfo.isOperatingSystemAtLeast(
            OperatingSystemVersion(majorVersion: 19, minorVersion: 0, patchVersion: 0)
        ) {
            return "bubbles.and.sparkles.fill"
        }
        return "lasso.badge.sparkles"
    }()
}
