//
//  UserStore.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 03/09/2024.
//  Copyright © 2024 Cédric Bahirwe. All rights reserved.
//

import Foundation
import SwiftUI

@MainActor
class UserStore: BaseViewModel {
    @Published private(set) var users: [DialerUser]
    @Published private(set) var recoveryCode: String?

    private let userProvider: UserProtocol

    init(_ userProvider: UserProtocol = FirebaseManager()) {
        self.users = []
        self.userProvider = userProvider
        super.init()
        Task {
            await getUsers()
        }
    }

    @MainActor
    func getUsers() async {
        startFetch()

        let result = await userProvider.getAllUsers()

        stopFetch()
        let sortedResult = result.sorted(by: { $0.username < $1.username })
        self.setUsers(to: sortedResult)
    }

    func setUsers(to newUsers: [DialerUser]) {
        self.users = newUsers
    }

    func isUsernameAvailable(_ username: String) -> Bool {
        !users.map(\.username).map({ $0.lowercased() }).contains(username.lowercased())
    }

    func saveUser(_ username: String) async -> Bool {
        let savedDevice = DialerStorage.shared.getSavedDevice()
        let device = savedDevice ?? FirebaseTracker.getDevice()
        let recoveryCode = ROT13.string(username) + "_" + ROT13.string(device.deviceHash.uuidString)

        let user = DialerUser(
            username: username,
            recoveryCode: recoveryCode,
            device: device
        )

        startFetch()
        do {
            let isUserSaved = try await userProvider.createUser(user)
            stopFetch()
            withAnimation {
                self.recoveryCode = recoveryCode
            }
            await getUsers()
            return isUserSaved
        } catch {
            Tracker.shared.logError(error: error)
            Log.debug("Could not save user: ", error)
            stopFetch()
            return false
        }
    }

    func deleteUser() async {
        do {
            guard let userId = DialerStorage.shared.getSavedDevice()?.deviceHash, !userId.uuidString.isEmpty else { return }
            _ = try await userProvider.deleteUser(userId)
        } catch {
            Log.debug("Could not delete user: ", error)
        }
    }

    func restoreUser(_ recoveryCode: String) async -> Bool {
        let components = recoveryCode.components(separatedBy: "_")
        guard components.count == 2 else { return  false }
        let username = ROT13.string(components[0])


        guard let user  = await userProvider.getUser(username: username)
        else { return false }

        let isRestored = user.recoveryCode == recoveryCode
        if isRestored {
            do {
                try DialerStorage.shared.saveDevice(user.device)
            } catch {
                Tracker.shared.logError(error: error)
                Log.debug(error.localizedDescription)
            }
        }
        return isRestored
    }

    struct ROT13 {
        // create a dictionary that will store our character mapping
        private static var key = [Character: Character]()

        // create arrays of all uppercase and lowercase letters
        private static let uppercase = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
        private static let lowercase = Array("abcdefghijklmnopqrstuvwxyz")

        static func string(_ string: String) -> String {
            // if this is the first time the method is being called, calculate the ROT13 key dictionary
            if ROT13.key.isEmpty {
                for i in 0 ..< 26 {
                    ROT13.key[ROT13.uppercase[i]] = ROT13.uppercase[(i + 13) % 26]
                    ROT13.key[ROT13.lowercase[i]] = ROT13.lowercase[(i + 13) % 26]
                }
            }

            // now return the transformed string
            let transformed = string.map { ROT13.key[$0] ?? $0 }
            return String(transformed)
        }
    }
}
