//
//  ForceUpdateManager.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 28/02/2023.
//

import SwiftUI

enum AppUpdateType: Int {
    case majorUpdates, minorUpdates, noUpdates
}

final class ForceUpdateManager: ObservableObject {
    private let minimalVersionNumbers = 2

    @Published private(set) var updateAlert: UpdateAlert?

    var isPresented: Binding<Bool> {
        Binding { [weak self] in
            self?.updateAlert != nil
        } set: { [weak self] newValue in
            guard !newValue else { return }
            self?.updateAlert = nil
        }
    }

    init() {
        checkAppVersion()
    }

    func checkAppVersion() {
        // Check if one full day has passed
        if let lastAskedDate = DialerStorage.shared.getLastAskedDateToUpdate() {
            guard Date.now.timeIntervalSince(lastAskedDate) >= 86_400 else { return }
        }

        guard  let storeAppVersion = RemoteConfigs.shared.string(for: .latestAppVersion) else { fatalError() }
        print("AppStore version", storeAppVersion)
        let update = getTypeOfUpdate(storeAppVersion: storeAppVersion)
        switch update {
        case .noUpdates:
            DialerStorage.shared.saveLastAskedDateToUpdate(nil)
            break
        case .majorUpdates:
            let actions = [
                UpdateAlert.Action("Download", action: openAppOnStore)
            ]
            self.updateAlert = .init(title: "Please, Update your app!",
                                     message: "You haven't updated your app for a long time! Quickly download the latest version to take advantage of the new features. It's quick and easy !",
                                     buttons: actions)

        case .minorUpdates:
            let actions: [UpdateAlert.Action] = [
                .init("Not Now", action:  {
                    DialerStorage.shared.saveLastAskedDateToUpdate(.now)
                }),
                .init("Download", action: openAppOnStore)
            ]

            self.updateAlert = .init(title: "New Version available!",
                                     message: "A new version of the app is available. Download it as soon as possible to enjoy all the latest features!",
                                     buttons: actions)

        }
    }

    private func getTypeOfUpdate(storeAppVersion: String) -> AppUpdateType {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        let currentVersionArray = version.components(separatedBy: ".")
        let storeVersionArray = storeAppVersion.components(separatedBy: ".")

        print("Ours", version, storeAppVersion, currentVersionArray)

        if (currentVersionArray.count > minimalVersionNumbers && storeVersionArray.count > minimalVersionNumbers) {
            let currentMajorVersion = currentVersionArray[0]
            let storeMajorVersion = storeVersionArray[0]
            if (currentMajorVersion < storeMajorVersion) {
                return .majorUpdates
            } else if (currentMajorVersion == storeMajorVersion) &&
                        (currentVersionArray[1] < storeVersionArray[1]) {
                return .minorUpdates
            }
        }

        DialerStorage.shared.saveLastAskedDateToUpdate(nil)
        return .noUpdates
    }

    private func openAppOnStore() {
        guard let appLink = URL(string: DialerlLinks.dialerAppStoreURL)
        else { return }
        UIApplication.shared.open(appLink, options: [:], completionHandler: nil)
    }
}


extension ForceUpdateManager {
    struct UpdateAlert: Identifiable {
        let id: UUID = UUID()
        let title: String
        let message: String
        let buttons: [UpdateAlert.Action]

        struct Action: Identifiable {
            let title: String
            let action: () -> Void

            var id: String { self.title }

            init(_ title: String, action: @escaping () -> Void) {
                self.title = title
                self.action = action
            }
        }

    }
}
