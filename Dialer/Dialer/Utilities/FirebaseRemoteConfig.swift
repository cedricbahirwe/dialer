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
    func bool(for key: RemoteConfigsFlag) -> Bool?
}

final class SBFirebaseRemoteConfig {

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

extension SBFirebaseRemoteConfig: RemoteConfigsProtocol {
    func fetchRemoteValues() async {
        let timeoutInterval = TimeInterval(fetchTimeout)
        do {
            let status = try await firebaseRemoteConfig.fetch(withExpirationDuration: fetchTimeout)
            if status == .success {
                debugPrint("Remote config fetched!")
                let isActivated = try await firebaseRemoteConfig.activate()
                if isActivated {
                    debugPrint("Remote Config Activated")
                } else {
                    debugPrint("Remote Config Not Activated")
                }
            }
        } catch {
            debugPrint("Error occured \(error.localizedDescription)")
        }
    }

    func string(for key: RemoteConfigsFlag) -> String? {
        firebaseRemoteConfig[key.rawValue].stringValue
    }

    func bool(for key: RemoteConfigsFlag) -> Bool? {
        firebaseRemoteConfig[key.rawValue].boolValue
    }
}

final class RemoteConfigs {
    private init() { }
    class var shared: RemoteConfigsProtocol {
        SBFirebaseRemoteConfig()
    }
}

enum RemoteConfigsFlag: String {
    case latestAppVersion = "latest_app_version"
}

