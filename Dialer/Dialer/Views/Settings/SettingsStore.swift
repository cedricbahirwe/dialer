//
//  SettingsStore.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 07/11/2024.
//  Copyright © 2024 Cédric Bahirwe. All rights reserved.
//

import Foundation
import AuthenticationServices

@MainActor final class SettingsStore: ObservableObject {
    @Published private(set) var isLoggedIn = false
    @Published private(set) var userInfo: AppleInfo? = DialerStorage.shared.getAppleInfo()
    private let userProvider : UserProtocol

    init(_ userProvider: UserProtocol = FirebaseManager()) {
        self.userProvider = userProvider
    }

    private func setUserInfo(_ userInfo: AppleInfo) {
        self.userInfo = userInfo
    }

    private func setIsLoggedIn(_ isLoggedIn: Bool) {
        self.isLoggedIn = isLoggedIn
    }

    private func updateDeviceWithAppleInfo(_ info: AppleInfo) {
        guard let device = DialerStorage.shared.getSavedDevice() else { return }

        Task {
            try await userProvider.saveUserAppleInfo(device.deviceHash, info: info)
        }
    }
}

// MARK: - Apple Sign In
extension SettingsStore {
    func checkAuthenticationState() async {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        do {
            let credentialState = try await appleIDProvider.credentialState(forUserID: KeychainItem.currentUserIdentifier)
            switch credentialState {
            case .authorized:
                isLoggedIn = true
            case .revoked, .notFound:
                // The Apple ID credential is either revoked or was not found.
                signoutFromApple()
            default:
                break
            }
        } catch {
            signoutFromApple()
        }
    }

    func signoutFromApple() {
        KeychainItem.deleteUserIdentifierFromKeychain()
        isLoggedIn = false
    }

    func handleAppleSignInCompletion(_ result: (Result<ASAuthorization, any Error>)) {
        switch result {
        case .success(let authResults):
            if let appleIDCredential  = authResults.credential as? ASAuthorizationAppleIDCredential {
                // Only Save info it does not exist
                let userIdentifier = appleIDCredential.user

                if let userInfo = DialerStorage.shared.getAppleInfo() {
                    setUserInfo(userInfo)
                    updateDeviceWithAppleInfo(userInfo)
                } else {
                    let fullName = appleIDCredential.fullName
                    let email = appleIDCredential.email

                    let info = AppleInfo(
                        userId: userIdentifier,
                        fullname: fullName,
                        email: email
                    )

                    setUserInfo(info)

                    do {
                        try DialerStorage.shared.saveAppleInfo(info)
                        updateDeviceWithAppleInfo(info)
                    } catch {
                        Tracker.shared.logError(error: error)
                    }
                }

                // Store the `userIdentifier` in the keychain.
                saveUserInKeychain(userIdentifier)
                setIsLoggedIn(true)
            }
        case .failure(let error):
            print("Auth Failed: ", error)
        }
    }
}


// MARK: - Keychain
private extension SettingsStore {
    func saveUserInKeychain(_ userIdentifier: String) {
        do {
            try KeychainItem(service: Bundle.main.bundleIdentifier!, account: "userIdentifier").saveItem(userIdentifier)
        } catch {
            print("Unable to save userIdentifier to keychain.")
        }
    }
}
