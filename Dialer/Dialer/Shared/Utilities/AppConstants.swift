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
    private static let merchantDigitsRangeDefault = 4...7
    static var merchantDigitsRange: ClosedRange<Int> {
        getMerchantDigitsRange()
    }
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

    private static func getMerchantDigitsRange() -> ClosedRange<Int> {
        let json  = RemoteConfigs.shared.string(for: .merchantDigitsRange) ?? ""
        let data = Data(json.utf8)
        let result = try? JSONDecoder().decode(MerchantDigitsRange.self, from: data)
        return result?.range ?? merchantDigitsRangeDefault
    }
}

private struct MerchantDigitsRange: Decodable {
    let min: Int
    let max: Int

    var range: ClosedRange<Int> {
        return min...max
    }
}
