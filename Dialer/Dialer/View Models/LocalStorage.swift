//
//  LocalStorage.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 09/08/2021.
//

import Foundation

#warning("Needs migration")
final class DialerStorage {
    typealias RecentCodes = [RecentDialCode]
    typealias ElectricityMeters = [ElectricityMeter]
    typealias USSDCodes = [USSDCode]
    
    private let LocalKeys = UserDefaults.Keys.self
    
    private let userDefaults = UserDefaults.standard
    
    static let shared = DialerStorage()
    
    private init() { }
    
    var hasPinCode: Bool {
        userDefaults.integer(forKey: LocalKeys.pinCode) != 0
    }
    
    func saveCodePin(_ value: CodePin) {
        userDefaults.setValue(value, forKey: LocalKeys.pinCode)
    }
    
    func getCodePin() -> CodePin? {
        print("I think of", userDefaults.value(forKey: LocalKeys.pinCode) as? String)
        return nil
//        return userDefaults.value(forKey: LocalKeys.pinCode) as? String
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

    func removeAllUSSDCodes() {
        userDefaults.removeObject(forKey: LocalKeys.customUSSDCodes)
    }
}

private extension  DialerStorage {
    func encodeData<T>(_ value: T) throws -> Data where T: Codable {
        return try JSONEncoder().encode(value)
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
