//
//  LocalStorage.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 09/08/2021.
//

import Foundation

public extension UserDefaults {
    
    /// Storing the used UserDefaults keys for safety.
    enum Keys {
        static let recentCodes = "recentCodes"
        static let pinCode = "pinCode"
        static let purchaseDetails = "purchaseDetails"
        static let lastSyncDate = "lastSyncDate"
        
        
        // Electricity
        static let meterNumbers = "meterNumbers"
        
        // Biometrics
        static let allowBiometrics = "allowBiometrics"
    }
}



final class DialerStorage {
    typealias RecentCodes = [RecentCode]
    typealias MeterNumbers = [MeterNumber]
    
    private let LocalKeys = UserDefaults.Keys.self
    
    private let userDefaults = UserDefaults.standard
    
    private init() { }
    
    static let shared = DialerStorage()
    
    
    var hasPinCode: Bool {
        userDefaults.integer(forKey: LocalKeys.pinCode) != 0
    }
    
    func savePinCode(_ value: Int) {
        userDefaults.setValue(value, forKey: LocalKeys.pinCode)
    }
    
    func getPinCode() -> Int? {
        userDefaults.value(forKey: LocalKeys.pinCode) as? Int

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
        let data = try encodeCustomData(codes)
        userDefaults.setValue(data, forKey: LocalKeys.recentCodes)
    }
    
    func getRecentCodes() -> RecentCodes {
        guard let codesData = userDefaults.object(forKey: LocalKeys.recentCodes) as? Data else {
            return []
        }
        
        do {
            return  try JSONDecoder().decode(RecentCodes.self, from: codesData)
        } catch let error {
            print("Couldn't decode the recent codes: " ,error.localizedDescription)
        }
        return []
    }
    
    func saveMeterNumbers(_ numbers: MeterNumbers) throws {
        let data = try encodeCustomData(numbers)
        userDefaults.setValue(data, forKey: LocalKeys.meterNumbers)
    }
    
    func getMeterNumbers() -> MeterNumbers {
        guard let meterNumbersData = userDefaults.object(forKey: LocalKeys.meterNumbers) as? Data else {
            return []
        }
        
        do {
            return  try JSONDecoder().decode(MeterNumbers.self, from: meterNumbersData)
        } catch let error {
            print("Couldn't decode the meter numbers: " ,error.localizedDescription)
        }
        return []
    }
    
}


private extension  DialerStorage {
    
    func encodeCustomData<T>(_ value: T) throws -> Data where T: Codable {
        return try JSONEncoder().encode(value)
    }
}
