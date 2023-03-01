//
//  FirebaseTracker.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 01/03/2023.
//

import Foundation
import FirebaseAnalytics
import DeviceCheck

class FirebaseTracker {
    private var sessions: [ScreenName: Date] = [:]

    init() {
        setAnalyticUserInfo()
    }

    private func setAnalyticUserInfo() {
        let device = getDeviceAccount()

        Analytics.setUserID(device.deviceIdentifier)
        Analytics.setUserProperty(device.appVersion, forName: "app_version")
        Analytics.setUserProperty(device.name, forName: "name")
        Analytics.setUserProperty(device.systemVersion, forName: "system_version")
        Analytics.setUserProperty(device.appVersion, forName: "app_version")



    }

    // MARK: - Session tracker
    enum Screen: String {
        case TeaserScreen // done
        case NotificationDeveloperSettingsScreen // not possible
        case AlbumScreen // done
        case SingleScreen // done
    }

    /// Creates a start time for a screen session.
    /// Date will be used in stop session method to get the session length
    /// - Parameter screen: Screen enum that indicates the screen to measure the session.
    func startSession(for screen: ScreenName) {
        sessions[screen] = Date()
    }

    /// Stops the session for a given screen.
    /// - Parameter screen: Screen enum value to measure the session.
    func stopSession(for screen: ScreenName) {
        /// 1. get the start date of the session
        guard let start = sessions[screen] else {
            debugPrint("could not get start time of the session for given screen: \(screen.rawValue)")
            return
        }
        /// 2. get the session length and format it as string and miliseconds
        let interval = start.timeIntervalSinceNow * (-1)
//        let formatted = interval.formattedString()
        let seconds: Int = Int(interval)
//        debugPrint("screen session time for: \(screen.rawValue) is \(formatted) seconds: \(seconds)")

        /// 3. log event on firebase
        // screen_session_length - Name of the Event
        // name - Name of the screen parameter
        // length - The session time in milliseconds
//        logEvent(name: AppAnalyticsEventType.screenSessionLength,
//                 parameters: [
//                    EventParameterKey.name.rawValue: screen.rawValue,
//                    EventParameterKey.length.rawValue: seconds
//                 ])
        /// 4. remove start date from cache
        sessions.removeValue(forKey: screen)
    }

    func getDeviceAccount() -> DeviceAccount {
        let device = UIDevice.current
        let deviceName = device.name
        let deviceModel = device.model
        let deviceSystemVersion = device.systemVersion
        let deviceSystemName = device.systemName
        let batteryLevel = UIDevice.current.batteryLevel
        let batteryState = UIDevice.current.batteryState.status
        let deviceIdentifier = (device.identifierForVendor ?? .init()).uuidString
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let bundleVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        let bundleID = Bundle.main.bundleIdentifier


        let deviceAccount = DeviceAccount(
            name: deviceName,
            model: deviceModel,
            systemVersion: deviceSystemVersion,
            sytemName: deviceSystemName,
            batteryLevel: Int(batteryLevel*100),
            batterState: batteryState,
            deviceIdentifier: deviceIdentifier,
            appVersion: appVersion,
            bundleVersion: bundleVersion,
            bundleId: bundleID)
        return deviceAccount
    }
}
