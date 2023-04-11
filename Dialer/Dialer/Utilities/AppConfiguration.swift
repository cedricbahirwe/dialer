//
//  AppConfiguration.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 01/03/2023.
//

import Foundation

enum AppConfiguration {
    enum Error: Swift.Error {
        case missingKey, invalidValue
    }

    static func firebaseConfigFileName() -> String? {
        return try? AppConfiguration.value(for: "DIALER_FIREBASE_FILE_NAME")
    }

    private static func value<T>(for key: String) throws -> T where T: LosslessStringConvertible {
        guard let object = Bundle.main.object(forInfoDictionaryKey:key) else {
            throw Error.missingKey
        }

        switch object {
        case let value as T:
            return value
        case let string as String:
            guard let value = T(string) else { fallthrough }
            return value
        default:
            throw Error.invalidValue
        }
    }
}
