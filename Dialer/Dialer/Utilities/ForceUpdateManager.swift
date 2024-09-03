//
//  ForceUpdateManager.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 28/02/2023.
//

import SwiftUI

enum AppUpdateType {
    case majorUpdate(_ version: String), minorUpdate(_ version: String), noUpdate
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
        // Checks if half day has passed (43,200 seconds)
        if let lastAskedDate = DialerStorage.shared.getLastAskedDateToUpdate() {
            guard Date.now.timeIntervalSince(lastAskedDate) >= 43_200 else { return }
        }

        guard  let storeAppVersion = RemoteConfigs.shared.string(for: .latestAppVersion) else { fatalError() }
        let update = getTypeOfUpdate(storeAppVersion: storeAppVersion)
        switch update {
        case .noUpdate:
            DialerStorage.shared.saveLastAskedDateToUpdate(nil)
            break
        case .majorUpdate(let version):
            let actions = [
                UpdateAlert.Action("Download v.\(version)", action: openAppOnStore)
            ]
            self.updateAlert = .init(title: "Please, Update your app!",
                                     message: "You haven't updated your app for a long time! Quickly download the latest version to take advantage of the new features. It's quick and easy !",
                                     buttons: actions)

        case .minorUpdate(let version):
            let actions: [UpdateAlert.Action] = [
                .init("Not Now", action:  {
                    DialerStorage.shared.saveLastAskedDateToUpdate(.now)
                }),
                .init("Download \(version)", action: openAppOnStore)
            ]

            self.updateAlert = .init(title: "New Version is available!",
                                     message: "A new version of the app is available. Download it as soon as possible to enjoy all the latest features!",
                                     buttons: actions)

        }
    }

    private func getTypeOfUpdate(storeAppVersion: String) -> AppUpdateType {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        let currentVersionArray = version.components(separatedBy: ".")
        let storeVersionArray = storeAppVersion.components(separatedBy: ".")

        if (currentVersionArray.count > minimalVersionNumbers && storeVersionArray.count > minimalVersionNumbers) {
            let currentMajorVersion = currentVersionArray[0]
            let storeMajorVersion = storeVersionArray[0]
            if (currentMajorVersion < storeMajorVersion) {
                return .majorUpdate(storeAppVersion)
            } else if (currentMajorVersion == storeMajorVersion) &&
                        (currentVersionArray[1] < storeVersionArray[1]) {
                return .minorUpdate(storeAppVersion)
            }
        }

        DialerStorage.shared.saveLastAskedDateToUpdate(nil)
        return .noUpdate
    }

    private func openAppOnStore() {
        guard let appLink = URL(string: DialerlLinks.dialerAppStoreURL)
        else { return }
        UIApplication.shared.open(appLink)
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
