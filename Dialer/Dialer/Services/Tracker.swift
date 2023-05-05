//
//  Tracker.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 01/03/2023.
//

import Foundation
import FirebaseFirestoreSwift

protocol TrackerProtocol: AnyObject {
    func logEvent(name: AnalyticsEventType, parameters: [String: Any]?)
    func logEvent(name: AnalyticsEventType)
    func logTransaction(transaction: Transaction)
    func logTransaction(transaction: Transaction, user: DeviceAccount)
    func logMerchantSelection(_ merchant: Merchant)
    func logSignIn(account: DeviceAccount)
    func logError(error: Error)
    func startSession(for screen: ScreenName)
    func stopSession(for screen: ScreenName)
    func logEvent(_ name: AppAnalyticsEventType)
}

extension TrackerProtocol {
    func logEvent(_ name: AppAnalyticsEventType) {
        logEvent(name: name)
    }
}

class Tracker {
    private init() { }
    static let shared: TrackerProtocol = FirebaseTracker()
}

protocol AnalyticsEventType {
    var stringValue: String { get }
}

enum AppAnalyticsEventType: String, AnalyticsEventType {
    case conctactsOpened = "contact_opened"
    
    case merchantCodeSelected
    
    case logIn = "app_login"
    case settingsOpened
    case transfer
    case airtime
    case history
    case mySpace
    case screenSessionLength

    case transaction

    
    var stringValue: String {
        self.rawValue.camelToSnake()
    }
}

enum EventParameterKey: String {
    // General
    case name
    case length

    // Transaction
    case transId = "tran_id"
    case transAmount = "tran_amount"
    case transType = "tran_type"
    case transCode = "tran_code"
    case transTime = "tran_timestamp"

    // Device
    case devId = "device_id"
    case devHash = "device_hash"
    case devVersion = "device_version"
}

enum LogEvent: String, AnalyticsEventType {
    case debugInfo
    case error

    var stringValue: String {
        rawValue
    }
}

struct DeviceAccount: Identifiable, Codable {
    @DocumentID var id: String?

    var name: String
    let model: String
    let systemVersion: String
    let systemName: String

    let deviceHash: String
    let appVersion: String?
    let bundleVersion: String?
    let bundleId: String?
    let lastVisitedDate: String?

    func toDictionary() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        dictionary["name"] = name
        dictionary["model"] = model
        dictionary["system_version"] = systemVersion
        dictionary["system_name"] = systemName
        dictionary["device_hash"] = deviceHash
        dictionary["app_version"] = appVersion
        dictionary["bundle_version"] = bundleVersion
        dictionary["bundle_id"] = bundleId
        dictionary["last_visited_date"] = lastVisitedDate
        return dictionary
    }
    
//    func toParamsDictionary() -> [String: Any] {
//        var dictionary: [String: Any] = [:]
//    }
}
