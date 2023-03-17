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


    private var completionContinuation: CheckedContinuation<[Decodable], Error>?


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

    func getMerchantsNear(lat: Double, long: Double) async -> [Merchant] {
        let merchants = await getAllMerchants()

        let userLocation = CLLocation(latitude: lat, longitude: long)

        let sortedMerchants = merchants.sorted {
            let location1 = CLLocation(latitude: $0.location.latitude,
                                       longitude: $0.location.longitude)

            let location2 = CLLocation(latitude: $1.location.latitude,
                                       longitude: $1.location.longitude)

            return userLocation.distance(from: location1) < userLocation.distance(from: location2)
        }
        return sortedMerchants
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
        guard let deviceID = device.id else { return false }
        return try await updateItemWithID(deviceID, content: device, in: .devices)
    }

    func deleteDevice(_ deviceID: String) async throws {
        try await deleteItemWithID(deviceID, in: .devices)
    }

    func getAllDevices() async -> [DeviceAccount] {
        await getAll(in: .devices)
    }

}

protocol MerchantProtocol {
    func createMerchant(_ merchant: Merchant) async throws-> Bool
    func getMerchant(by id: String) async -> Merchant?
    func updateMerchant(_ merchant: Merchant) async throws-> Bool
    func deleteMerchant(_ merchantID: String) async throws
    func getAllMerchants() async -> [Merchant]
    func getMerchantsNear(lat: Double, long: Double) async -> [Merchant]
}

protocol DeviceManagerProtocol {
    func saveDevice(_ device: DeviceAccount) async throws -> Bool
    func getDevice(by id: String) async -> DeviceAccount?
    func updateDevice(_ device: DeviceAccount) async throws -> Bool
    func deleteDevice(_ deviceID: String) async throws
    func getAllDevices() async -> [DeviceAccount]
}
