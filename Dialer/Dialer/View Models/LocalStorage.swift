//
//  LocalStorage.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 09/08/2021.
//

import Foundation
import FirebaseFirestore

final class DialerStorage {
    typealias RecentCodes = [RecentDialCode]
    typealias USSDCodes = [USSDCode]
    
    private let LocalKeys = UserDefaultsKeys.self
    
    private let userDefaults = UserDefaults.standard
    
    static let shared = DialerStorage()
    
    private init() {
        // Delete PinCode if it exists for all devices
        // Note: Remove this in next version + 1
        removePinCode()
    }
    
    func saveOneTimeUniqueAppID() {
        guard getOneTimeUniqueAppID() == nil else { return }
        userDefaults.setValue(UUID().uuidString, forKey: LocalKeys.appUniqueID)
    }
    
    func getOneTimeUniqueAppID() -> UUID? {
        guard let uniqueIDString = userDefaults.value(forKey: LocalKeys.appUniqueID) as? String,
              let uniqueID = UUID(uuidString: uniqueIDString) else {
            return nil
        }
        return uniqueID
    }

    
    func removePinCode() {
        userDefaults.removeObject(forKey: LocalKeys.pinCode)
    }
    
    /// Store the Last Sync date if it does not exist
    func storeSyncDate() {
        let syncDateKey = LocalKeys.lastSyncDate
        if userDefaults.value(forKey: syncDateKey) != nil { return }
        userDefaults.setValue(Date(), forKey: syncDateKey)
    }
    
    /// Remove the existing last sync date, so it can be stored on the next app launch
    func clearSyncDate() {
        userDefaults.setValue(nil, forKey: LocalKeys.lastSyncDate)
    }
    
    /// Check whether 1 month period has been reached since last sync date
    /// - Parameter date: the last sync date
    /// - Returns: true is the sync date has been reached
    func isSyncDateReached() -> Bool {
        
        if let lastSyncDate = userDefaults.value(forKey: LocalKeys.lastSyncDate) as? Date {
            // To check if 30 Days have passed
            return Date().timeIntervalSince(lastSyncDate) / 86400 > 30
        }
        
        return false
    }
    
//    func saveRecentCodes(_ codes: RecentCodes) throws {
//        let data = try encodeData(codes)
//        userDefaults.setValue(data, forKey: LocalKeys.recentCodes)
//    }
//    
    func getSortedRecentCodes() -> RecentCodes {
        decodeDatasArray(key: LocalKeys.recentCodes, type: RecentCodes.self)
            .sorted { $0.detail.purchaseDate > $1.detail.purchaseDate }
    }

    func clearRecentCodes() {
        userDefaults.removeObject(forKey: LocalKeys.recentCodes)
    }

    func saveUSSDCodes(_ ussds: USSDCodes) throws {
        let data = try encodeData(ussds)
        userDefaults.setValue(data, forKey: LocalKeys.customUSSDCodes)
    }

    func getUSSDCodes() -> USSDCodes {
        decodeDatasArray(key: LocalKeys.customUSSDCodes, type: USSDCodes.self)
    }

    func saveLastAskedDateToUpdate(_ date: Date?) {
        userDefaults.set(date, forKey: LocalKeys.lastAskedDateToUpdate)
    }

    func getLastAskedDateToUpdate() -> Date? {
        userDefaults.value(forKey: LocalKeys.lastAskedDateToUpdate) as? Date
    }

    func saveDevice(_ device: DeviceAccount) throws {
        let data = try encodeDataWithFirebase(device)
        userDefaults.set(data, forKey: LocalKeys.deviceAccount)
    }

    func getSavedDevice() -> DeviceAccount? {
        guard let userDevice = decodeDataWithFirebase(key: LocalKeys.deviceAccount, as: DeviceAccount.self)
        else { return nil }
        return userDevice
    }

    func removeAllUSSDCodes() {
        userDefaults.removeObject(forKey: LocalKeys.customUSSDCodes)
    }
    
    func setDailyNotificationStatus(to isEnabled: Bool) {
        userDefaults.set(isEnabled, forKey: LocalKeys.dailyNotificationEnabled)
    }
    
    func isDailyNotificationEnabled() -> Bool {
        userDefaults.bool(forKey: LocalKeys.dailyNotificationEnabled)
    }

    func saveAppleInfo(_ info: AppleInfo) throws {
        let data = try encodeData(info)
        userDefaults.set(data, forKey: LocalKeys.appleSignInInfo)
    }

    func getAppleInfo() -> AppleInfo? {
        decodeData(key: LocalKeys.appleSignInInfo, as: AppleInfo.self)
    }

    func removeAppleSignInInfo() {
        userDefaults.removeObject(forKey: LocalKeys.appleSignInInfo)
    }
}

private extension DialerStorage {
    func encodeDataWithFirebase<T>(_ value: T) throws -> [String: Any] where T: Codable {
        let dictionary = try Firestore.Encoder().encode(value)
        
        return dictionary
    }
    
    func decodeDataWithFirebase<T: Decodable>(key: String, as type: T.Type) -> T? {
        guard let dictionary = userDefaults.object(forKey: key) as? [String: Any] else {
            userDefaults.removeObject(forKey: key)
            return nil
        }
        
        do {
            return try Firestore.Decoder().decode(type, from: dictionary)
        } catch let error {
            Log.debug("Couldn't decode the firebase data of type \(type): ", error)
        }
        return nil
    }
    
    func encodeData<T>(_ value: T) throws -> Data where T: Codable {
        return try JSONEncoder().encode(value)
    }

    func decodeData<T: Decodable>(key: String, as type: T.Type) -> T? {
        guard let data = userDefaults.object(forKey: key) as? Data else {
            return nil
        }
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch let error {
            Log.debug("Couldn't decode the data of type \(type): ", error.localizedDescription)
        }
        return nil
    }

    func decodeDatasArray<T: Codable>(key: String, type:  Array<T>.Type) -> [T] {
        guard let data = userDefaults.object(forKey: key) as? Data else {
            userDefaults.removeObject(forKey: key)
            return []
        }
        do {
            return  try JSONDecoder().decode(type, from: data)
        } catch let error {
            Log.debug("Couldn't decode the array of type \(type): ", error.localizedDescription)
        }
        return []
    }
}
