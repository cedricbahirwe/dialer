//
//  FirebaseManager.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 26/02/2023.
//

import CoreLocation
import FirebaseFirestore

class FirebaseManager: FirebaseCRUD {
    private(set) lazy var db = Firestore.firestore()
}

// MARK: - Merchant Provider
extension FirebaseManager: MerchantProtocol {

    func createMerchant(_ merchant: Merchant) async throws -> Bool {
        try await create(merchant, in: .merchants)
    }

    func getMerchant(by merchantID: String) async -> Merchant? {
        await getItemWithID(merchantID, in: .merchants)

    }

    func updateMerchant(_ merchant: Merchant) async throws -> Bool {
        guard let merchantID = merchant.id else { return false }
        
        return try await updateItemWithID(merchantID,
                                      content: merchant,
                                      in: .merchants)
    }

    func deleteMerchant(_ merchantID: String) async throws {
        try await deleteItemWithID(merchantID, in: .merchants)
    }

    func getAllMerchants() async -> [Merchant] {
        await getAll(in: .merchants)
    }

    func getMerchantsFor(_ userID: UUID) async -> [Merchant] {
        do {
            let querySnapshot = try await db.collection(.merchants)
                .whereField("ownerId", isEqualTo: userID.uuidString)
                .order(by: "name")
                .getDocuments()
            
            return await getAllWithQuery(querySnapshot)
            
        } catch {
            Log.debug("Can not get \(type(of: Merchant.self)), Error: \(error).")
            Tracker.shared.logError(error: error)
            return []
        }
    }

}

// MARK: - Device Provider

extension FirebaseManager: DeviceManagerProtocol {
    func saveDevice(_ device: DeviceAccount) async throws -> Bool {
        try await create(device, in: .devices)
    }

    func getDevice(by id: String) async -> DeviceAccount? {
        await getItemWithID(id, in: .devices)
    }

    func updateDevice(_ device: DeviceAccount) async throws -> Bool {
        updateUserDevice(device)
        return try await updateItemWithID(device.deviceHash.uuidString, content: device, in: .devices)
    }

    private func updateUserDevice(_ device: DeviceAccount) {
        Task {
            if let docID = try? await db.collection(.users)
                .whereField("device.deviceHash", isEqualTo: device.deviceHash.uuidString)
                .getDocuments()
                .documents.first?.documentID {
                let deviceDictionary = try Firestore.Encoder().encode(device)

                try await db.collection(.users)
                    .document(docID)
                    .updateData(["device": deviceDictionary])
            }
        }
    }

    func deleteDevice(_ deviceID: String) async throws {
        try await deleteItemWithID(deviceID, in: .devices)
    }

    func getAllDevices() async -> [DeviceAccount] {
        await getAll(in: .devices)
    }

}


extension FirebaseManager: InsightProtocol {
    func saveInsight(_ insight: TransactionInsight) async throws -> Bool {
        try await create(insight, in: .transactions)
    }

    func getAllInsights() async -> [TransactionInsight] {
        await getAll(in: .transactions)
    }

    func getInsights(for userID: UUID) async -> [TransactionInsight] {
        do {
            let querySnapshot = try await db.collection(.transactions)
                .whereField("ownerId", isEqualTo: userID.uuidString)
                .getDocuments()

            return await getAllWithQuery(querySnapshot)

        } catch {
            Log.debug("Can not get \(type(of: TransactionInsight.self)), Error: \(error).")
            Tracker.shared.logError(error: error)
            return []
        }
    }
}

extension FirebaseManager: UserProtocol {

    func createUser(_ user: DialerUser) async throws -> Bool {
        try await create(user, in: .users)
    }

    func getUser(by id: String) async -> DialerUser? {
        nil
    }

    func getUser(username: String) async -> DialerUser? {
        do {
            let snapshot = try await db.collection(.users)
                .whereField("username", isEqualTo: username)
                .limit(to: 1)
                .getDocuments()

            let item = try snapshot.documents.first?.data(as: DialerUser.self)

            return item
        } catch {
            Tracker.shared.logError(error: error)
            Log.debug("Can not get \(type(of: DialerUser.self)), Error: \(error).")
            return nil
        }
    }

    func updateUser(_ user: DialerUser) async throws -> Bool {
        false
    }

    func deleteUser(_ userID: String) async throws {
        fatalError()
    }

    func getAllUsers() async -> [DialerUser] {
        await getAll(in: .users)
    }

    func saveUserAppleInfo(_ userID: UUID, info: AppleInfo) async throws -> Bool {
        guard let docID = try? await db.collection(.users)
            .whereField("device.deviceHash", isEqualTo: userID.uuidString)
            .getDocuments()
            .documents.first?.documentID else { return false }
        let deviceDictionary = try Firestore.Encoder().encode(info)

        try await db.collection(.users)
            .document(docID)
            .updateData(["apple": deviceDictionary])
        print("Reache")
        return true
    }
}

protocol MerchantProtocol {
    func createMerchant(_ merchant: Merchant) async throws-> Bool
    func getMerchant(by id: String) async -> Merchant?
    func updateMerchant(_ merchant: Merchant) async throws-> Bool
    func deleteMerchant(_ merchantID: String) async throws
    func getAllMerchants() async -> [Merchant]
    func getMerchantsFor(_ userID: UUID) async -> [Merchant]
}

protocol UserProtocol {
    func createUser(_ user: DialerUser) async throws-> Bool
    func getUser(by id: String) async -> DialerUser?
    func getUser(username: String) async -> DialerUser?
    func updateUser(_ user: DialerUser) async throws-> Bool
    func deleteUser(_ userID: String) async throws
    func getAllUsers() async -> [DialerUser]
    func saveUserAppleInfo(_ userID: UUID, info: AppleInfo) async throws -> Bool
}

protocol DeviceManagerProtocol {
    func saveDevice(_ device: DeviceAccount) async throws -> Bool
    func getDevice(by id: String) async -> DeviceAccount?
    func updateDevice(_ device: DeviceAccount) async throws -> Bool
    func deleteDevice(_ deviceID: String) async throws
    func getAllDevices() async -> [DeviceAccount]
}

protocol InsightProtocol {
    func saveInsight(_ insight: TransactionInsight) async throws -> Bool
    func getAllInsights() async -> [TransactionInsight]
    func getInsights(for userID: UUID) async -> [TransactionInsight]
}
