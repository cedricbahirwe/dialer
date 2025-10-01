//
//  FirebaseTracker.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 01/03/2023.
//

import Foundation
import FirebaseAnalytics

class FirebaseTracker {
    private var sessions: [ScreenName: Date] = [:]
    private let deviceProvider: DeviceManagerProtocol

    init(_ deviceProvider: DeviceManagerProtocol = FirebaseManager()) {
        self.deviceProvider = deviceProvider
        setAnalyticUserInfo()
    }

    private func setAnalyticUserInfo() {
        var device = FirebaseTracker.getDevice()
        device.lastVisitedDate = FirebaseTracker.formattedCurrentDateTime()

        Analytics.setUserID(device.deviceHash.uuidString)
        Analytics.setUserProperty(device.appVersion, forName: "app_version")
        Analytics.setUserProperty(device.name, forName: "name")
        Analytics.setUserProperty(device.systemVersion, forName: "system_version")
        Analytics.setUserProperty(device.appVersion, forName: "app_version")

        Task {
            do {
                let isSaved = try await deviceProvider.updateDevice(device)
                if isSaved {
                    do {
                        try DialerStorage.shared.saveDevice(device)
                        logSignIn(account: device)
                    } catch {
                        logError(error: error)
                    }
                }
            }
        }
    }

    func logAnalyticsEvent(_ eventName: String, parameters: [String: Any]?) {
        Analytics.logEvent(
            eventName,
            parameters: parameters
        )
    }

    func recordTransaction(_ details: RecordDetails) {
        guard let crudManager = self.deviceProvider as? FirebaseCRUD else { return }
        let device = FirebaseTracker.getDevice()

        let insight = TransactionInsight(details: details, ownerID: device.deviceHash)
        Task {
            do {
                _ = try await crudManager.create(insight, in: .transactions)
            } catch {
                Log.debug("Insight Creation error:", error.localizedDescription)
            }
        }
    }

    // MARK: - Session tracker

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
            Log.debug("could not get start time of the session for given screen: \(screen.rawValue)")
            return
        }
        /// 2. get the session length and format it as string and miliseconds
        let interval = start.timeIntervalSinceNow * (-1)
        let formatted = interval.formattedString()
        let seconds: Int = Int(interval)
        Log.debug("screen session time for: \(screen.rawValue) is \(formatted) seconds: \(seconds)")

        /// 3. log event on firebase
        // screen_session_length - Name of the Event
        // name - Name of the screen parameter
        // length - The session time in milliseconds
#if DEBUG
#else
        logEvent(name: AppAnalyticsEventType.screenSessionLength,
                 parameters: [
                    EventParameterKey.name.rawValue: screen.rawValue,
                    EventParameterKey.length.rawValue: seconds
                 ])
#endif

        /// 4. remove start date from cache
        sessions.removeValue(forKey: screen)
    }

    static func getDevice() -> DeviceAccount {
        if let storedDevice = DialerStorage.shared.getSavedDevice() {
            return refreshMetadata(storedDevice)
        }
        return makeDeviceAccount()
    }

    private static func makeDeviceAccount() -> DeviceAccount {
        let metadata = getDeviceMetadata()
        return DeviceAccount(
            id: metadata.deviceIdentifier.uuidString,
            name: metadata.deviceName,
            model: metadata.deviceModel,
            systemVersion: metadata.deviceSystemVersion,
            systemName: metadata.deviceSystemName,
            deviceHash: metadata.deviceIdentifier,
            appVersion: metadata.appVersion,
            bundleVersion: metadata.bundleVersion,
            lastVisitedDate: formattedCurrentDateTime()
        )
    }

    private static func refreshMetadata(_ device: DeviceAccount) -> DeviceAccount {
        var updatedDevice = device
        let metadata = getDeviceMetadata()

        updatedDevice.name = metadata.deviceName
        updatedDevice.model = metadata.deviceModel
        updatedDevice.systemVersion = metadata.deviceSystemVersion
        updatedDevice.systemName = metadata.deviceSystemName
        updatedDevice.appVersion = metadata.appVersion
        updatedDevice.bundleVersion = metadata.bundleVersion
        updatedDevice.lastVisitedDate = formattedCurrentDateTime()

        return updatedDevice
    }

    private static func formattedCurrentDateTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: Date())
    }

    private static func getDeviceMetadata() -> (deviceName: String, deviceModel: String, deviceSystemVersion: String, deviceSystemName: String, deviceIdentifier: UUID, appVersion: String?, bundleVersion: String?, bundleID: String?) {
        let device = UIDevice.current
        let deviceName = device.name
        let deviceModel = device.model
        let deviceSystemVersion = device.systemVersion
        let deviceSystemName = device.systemName
        let deviceIdentifier = DialerStorage.shared.getOneTimeUniqueAppID()!
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let bundleVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        let bundleID = Bundle.main.bundleIdentifier

        return (deviceName, deviceModel, deviceSystemVersion, deviceSystemName, deviceIdentifier, appVersion, bundleVersion, bundleID)
    }
}
