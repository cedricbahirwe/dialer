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
    func logTransaction(transaction: Transaction)
    func logTransaction(transaction: Transaction, user: DeviceAccount)
    func logSignIn(account: DeviceAccount)
    func logError(error: Error)
    func startSession(for screen: ScreenName)
    func stopSession(for screen: ScreenName)
}

class Tracker {
    private init() { }
    static let shared: TrackerProtocol = FirebaseTracker()
}

protocol AnalyticsEventType {
    var stringValue: String { get }
}

enum AppAnalyticsEventType: String, AnalyticsEventType {
    case dashboard
    case settingsOpened = "settings_opened"
    case transaction
    case send
    case history
    case mySpace = "my_space"
    case screenSessionLength = "screen_session_length"

    var stringValue: String {
        self.rawValue
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
