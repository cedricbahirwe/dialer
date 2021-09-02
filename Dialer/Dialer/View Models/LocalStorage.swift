//
//  LocalStorage.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 09/08/2021.
//

import Foundation

private extension UserDefaults {
    
    /// Storing the used UserDefaults keys for safety.
    enum Keys {
        static let RecentCodes = "recentCodes"
        static let PinCode = "pinCode"
        static let PurchaseDetails = "purchaseDetails"
        static let LastSyncDate = "lastSyncDate"
    }
}


class DialerStorage {
    typealias RecentCodes = [MainViewModel.RecentCode]
    private let LocalKeys = UserDefaults.Keys.self
    
    private let userDefaults = UserDefaults.standard
    
    private init() { }
    
    static let shared = DialerStorage()
    
    
    func hasPinCode() -> Bool {
        userDefaults.integer(forKey: LocalKeys.PinCode) != 0
    }
    
    func savePinCode(_ value: Int) {
        userDefaults.setValue(value, forKey: LocalKeys.PinCode)
    }
    
    func getPinCode() -> Int? {
        userDefaults.value(forKey: LocalKeys.PinCode) as? Int

    }
    
    func removePinCode() {
        userDefaults.removeObject(forKey: LocalKeys.PinCode)
    }
    
    /// Store the Last Sync date if it does not exist
    func storeSyncDate() {
        
        let syncDateKey = LocalKeys.LastSyncDate
        if userDefaults.value(forKey: syncDateKey) != nil { return }
        userDefaults.setValue(Date(), forKey: syncDateKey)
    }
    
    
    /// Remove the existing last sync date, so it can be stored on the next app launch
    func clearSyncDate() {
        userDefaults.setValue(nil, forKey: LocalKeys.LastSyncDate)
    }
    
    /// Check whether 1 month period has been reached since last sync date
    /// - Parameter date: the last sync date
    /// - Returns: true is the sync date has been reached
    func isSyncDateReached() -> Bool {
        
        if let lastSyncDate = userDefaults.value(forKey: LocalKeys.LastSyncDate) as? Date {
            // T0 check if 30 Days have passed
           return Date().timeIntervalSince(lastSyncDate) / 86400 > 30
        }
        
        return false
    }
    
    func saveRecentCodes(_ values: RecentCodes?) throws {
        let data = try encodeCustomData(values)
        userDefaults.setValue(data, forKey: LocalKeys.RecentCodes)
    }
    
    func getRecentCodes() -> RecentCodes? {
        guard let codes = userDefaults.object(forKey: LocalKeys.RecentCodes) as? Data else {
            return nil
        }
        do {
            return  try JSONDecoder().decode(RecentCodes.self, from: codes)
        } catch let error {
            print("Couldn't decode the recent codes")
            print(error.localizedDescription)
        }
        return nil
    }
    
}


extension  DialerStorage {
    

    
    func encodeCustomData<V>(_ value: V) throws -> Data where V: Codable {
        return try JSONEncoder().encode(value)
    }
}