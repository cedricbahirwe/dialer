//
//  LocalStorage.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 09/08/2021.
//

import Foundation

final class DialerStorage {
    typealias RecentCodes = [RecentDialCode]
    typealias ElectricityMeters = [ElectricityMeter]
    typealias USSDCodes = [USSDCode]
    
    private let LocalKeys = UserDefaults.Keys.self
    
    private let userDefaults = UserDefaults.standard
    
    static let shared = DialerStorage()
    
    private init() { }

    func saveCodePin(_ value: CodePin) throws {
        let data = try encodeData(value)
        userDefaults.setValue(data, forKey: LocalKeys.pinCode)
    }
    
    func getCodePin() -> CodePin? {
        // Handle Migration
        if let code = userDefaults.value(forKey: LocalKeys.pinCode) as? Int {
            return try? CodePin(code)
        } else {
            return decodeData(key: LocalKeys.pinCode, as: CodePin.self)
        }
    }

    func hasSavedCodePin() -> Bool {
        getCodePin() != nil
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
    
    func saveRecentCodes(_ codes: RecentCodes) throws {
        let data = try encodeData(codes)
        userDefaults.setValue(data, forKey: LocalKeys.recentCodes)
    }
    
    func getRecentCodes() -> RecentCodes {
        decodeDatasArray(key: LocalKeys.recentCodes, type: RecentCodes.self)
    }
    
    func saveElectricityMeters(_ meters: ElectricityMeters) throws {
        let data = try encodeData(meters)
        userDefaults.setValue(data, forKey: LocalKeys.meterNumbers)
    }
    
    func getMeterNumbers() -> ElectricityMeters {
        decodeDatasArray(key: LocalKeys.meterNumbers, type: ElectricityMeters.self)
    }

    func saveUSSDCodes(_ ussds: USSDCodes) throws {
        let data = try encodeData(ussds)
        userDefaults.setValue(data, forKey: LocalKeys.customUSSDCodes)
    }

    func getUSSDCodes() -> USSDCodes {
        decodeDatasArray(key: LocalKeys.customUSSDCodes, type: USSDCodes.self)
    }

    func saveLastKnownLocation(_ userLocation: UserLocation) throws {
        let data = try encodeData(userLocation)
        userDefaults.setValue(data, forKey: LocalKeys.lastUserLocation)
    }

    func getLastKnownLocation() -> UserLocation? {
        guard let userLocation = decodeData(key: LocalKeys.lastUserLocation, as: UserLocation.self)
        else { return nil }
        return userLocation
    }

    func saveLastAskedDateToUpdate(_ date: Date?) {
        userDefaults.set(date, forKey: LocalKeys.lastAskedDateToUpdate)
    }

    func getLastAskedDateToUpdate() -> Date? {
        userDefaults.value(forKey: LocalKeys.lastAskedDateToUpdate) as? Date
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
}

private extension  DialerStorage {
    func encodeData<T>(_ value: T) throws -> Data where T: Codable {
        return try JSONEncoder().encode(value)
    }

    func decodeData<T: Decodable>(key: String, as type: T.Type) -> T? {
        guard let data = userDefaults.object(forKey: key) as? Data else {
            return nil
        }
        do {
            return  try JSONDecoder().decode(type, from: data)
        } catch let error {
            print("Couldn't decode the data of type \(type): ", error.localizedDescription)
        }
        return nil
    }

    func decodeDatasArray<T: Codable>(key: String, type:  Array<T>.Type) -> [T] {
        guard let data = userDefaults.object(forKey: key) as? Data else {
            return []
        }
        do {
            return  try JSONDecoder().decode(type, from: data)
        } catch let error {
            print("Couldn't decode the data of type \(type): ", error.localizedDescription)
        }
        return []
    }
}
