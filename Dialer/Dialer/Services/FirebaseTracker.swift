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

    func setAnalyticUserInfo() {
        let device = FirebaseTracker.makeDeviceAccount()

        Analytics.setUserID(device.deviceHash)
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

    func recordTransaction(_ transaction: Transaction) {
        guard let crudManager = self.deviceProvider as? FirebaseCRUD else { return }
        let record = RecordInsight(details: .momo(transaction))
        Task {
            do {
                let created = try await crudManager.create(record, in: .transactions)
                print("Record created", created)
            } catch {
                print("Record error:")
                print(error.localizedDescription)
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

    static func makeDeviceAccount() -> DeviceAccount {
        let device = UIDevice.current
        let deviceName = device.name
        let deviceModel = device.model
        let deviceSystemVersion = device.systemVersion
        let deviceSystemName = device.systemName
        let deviceIdentifier = DialerStorage.shared.getOneTimeUniqueAppID()!.uuidString
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let bundleVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        let bundleID = Bundle.main.bundleIdentifier
        
        let deviceAccount = DeviceAccount(
            id: deviceIdentifier,
            name: deviceName,
            model: deviceModel,
            systemVersion: deviceSystemVersion,
            systemName: deviceSystemName,
            deviceHash: deviceIdentifier,
            appVersion: appVersion,
            bundleVersion: bundleVersion,
            bundleId: bundleID,
            lastVisitedDate: Date.now.formatted())
        
        return deviceAccount
    }
}
