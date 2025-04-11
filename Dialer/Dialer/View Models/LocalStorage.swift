//
//  LocalStorage.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 09/08/2021.
//

import Foundation
import FirebaseFirestore

final class DialerStorage {
    typealias USSDCodes = [USSDCode]

    private let userDefaults = UserDefaults.standard

    static let shared = DialerStorage()

    private init() {}

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

    func clearDevice() {
        userDefaults.removeObject(forKey: LocalKeys.deviceAccount)
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
