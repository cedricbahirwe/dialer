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
    @Published private var users: [DialerUser]
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

        let user = DialerUser(
            username: username,
            device: device
        )

        startFetch()
        do {
            let isUserSaved = try await userProvider.createUser(user)
            stopFetch()
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
            let didDelete = try await userProvider.deleteUser(userId)
            if didDelete {
                await getUsers()
            }
        } catch {
            Log.debug("Could not delete user: ", error)
        }
    }
}
