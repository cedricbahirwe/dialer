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
    case subscriptionPurchase = "subscription_purchase"
    case songDownloaded = "song_downloaded"
    case wawChange = "waw_change"
    case accountCreated = "sign_up"
    case login
    case accountDeleted = "delete_account"
    case songPlayed = "song_played"
    case share = "share"
    case pageView = "page_view"
    case emitedCoupon = "coupon_emited"
    case usedCoupon = "coupon_used"
    case adsImpression = "ads_impression"
    case screenSessionLength = "screen_session_length"
    case screenView = "screen_view"

    var stringValue: String {
        self.rawValue
    }
}

enum EventParameterKey: String {
    case subscriptionType = "subscription_type"
    case paymentType = "payment_type"
    case price = "price"
    case networkMode = "network_mode"
    case songName = "song_name"
    case songId = "song_id"
    case albumId = "album_id"
    case albumName = "album_name"
    case artistName = "artist_name"
    case artistId = "artist_id"
    case genre
    case jukebox
    case playlistId = "playlist_id"
    case userId = "user_id"
    case accountType = "account_type"
    case value
    case type
    case couponType = "coupon_type"
    case name
    case length
    case formatted
    case songTitle = "song_title"
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
    let sytemName: String
    let batteryLevel: Int
    let batterState: String

    let deviceIdentifier: String
    let appVersion: String?
    let bundleVersion: String?
    let bundleId: String?
}
