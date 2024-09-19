//
//  Tracker.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 01/03/2023.
//

import Foundation
import FirebaseFirestore

protocol AnalyticsEventType {
    var stringValue: String { get }
}

protocol TrackerProtocol: AnyObject {
    func logEvent(name: AnalyticsEventType, parameters: [String: Any]?)
    func logEvent(name: AnalyticsEventType)
    func logTransaction(transaction: Transaction)
    func logTransaction(record: RecordDetails)
    func logMerchantSelection(_ merchant: Merchant)
    func logMerchantScan(_ merchantCode: String)
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

final class Tracker {
    private init() { }
    static let shared: TrackerProtocol = FirebaseTracker()
}

enum AppAnalyticsEventType: String, AnalyticsEventType {
    
    // Screens
    case settingsOpened
    case transferOpened
    case airtimeOpened
    case mySpaceOpened
    
    // Activities
    case screenSessionLength

    // Actions
    case transaction
    case merchantCodeSelected
    case conctactsOpened = "contact_opened"
    case logIn = "app_login"
    case merchantCodeScanned
    var stringValue: String {
        rawValue.camelToSnake()
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
