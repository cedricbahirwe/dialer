//
//  UserStore.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 03/09/2024.
//  Copyright © 2024 Cédric Bahirwe. All rights reserved.
//

import Foundation
import SwiftUI

class UserStore: BaseViewModel, ObservableObject {
    @Published private(set) var users: [DialerUser]
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
        print("Got users", result.count)

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

    @Published var recoveryCode: String?

    func saveUser(_ username: String) async -> Bool {
        let savedDevice = DialerStorage.shared.getSavedDevice()
        let device = savedDevice ?? FirebaseTracker.makeDeviceAccount()
        let recoveryCode = ROT13.string(username.uppercased()) + "_" + ROT13.string(device.deviceHash)

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
