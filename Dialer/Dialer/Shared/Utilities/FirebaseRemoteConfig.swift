//
//  FirebaseRemoteConfig.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 28/02/2023.
//

import FirebaseRemoteConfig

protocol RemoteConfigsProtocol: AnyObject {
    func fetchRemoteValues() async
    func string(for key: RemoteConfigsFlag) -> String?
    func bool(for key: RemoteConfigsFlag) -> Bool
}

final class FirebaseRemoteConfig {

    private let fetchTimeout: Double = 0.0 // seconds
    private var firebaseRemoteConfig: RemoteConfig!

    init() {
        firebaseRemoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = fetchTimeout

        if let inAppVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            firebaseRemoteConfig.setDefaults([RemoteConfigsFlag.latestAppVersion.rawValue: NSString(string: inAppVersion)])
        }
        firebaseRemoteConfig.configSettings = settings
    }
}

extension FirebaseRemoteConfig: RemoteConfigsProtocol {
    func fetchRemoteValues() async {
        do {
            let status = try await firebaseRemoteConfig.fetch(withExpirationDuration: fetchTimeout)
            if status == .success {
                _ = try await firebaseRemoteConfig.activate()
      
            }
        } catch {
            Log.debug("Error occured \(error.localizedDescription)")
        }
    }

    func string(for key: RemoteConfigsFlag) -> String? {
        firebaseRemoteConfig[key.rawValue].stringValue
    }

    func bool(for key: RemoteConfigsFlag) -> Bool {
        firebaseRemoteConfig[key.rawValue].boolValue
    }
}

final class RemoteConfigs {
    private init() { }
    class var shared: RemoteConfigsProtocol {
        FirebaseRemoteConfig()
    }
}

enum RemoteConfigsFlag: String {
    case latestAppVersion = "latest_app_version"
    case show2024Wrapped = "show_2024_wrapped"
    case merchantDigitsRange = "merchant_digits_range"
}

