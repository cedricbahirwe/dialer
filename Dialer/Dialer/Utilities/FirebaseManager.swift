//
//  FirebaseManager.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 26/02/2023.
//

import CoreLocation
import FirebaseFirestore

protocol MerchantProtocol {
    func createMerchant(_ merchant: Merchant) async -> Bool
    func getMerchant(by id: String) async -> Merchant?
    func updateMerchant(_ merchant: Merchant) async -> Bool
    func deleteMerchant(_ merchantID: String) async throws
    func getAllMerchants() async -> [Merchant]
    func getMerchantsNear(lat: Double, long: Double) async -> [Merchant]
}

protocol DeviceProtocol {
    func saveDevice(_ device: DeviceAccount) async -> Bool
    func getDevice(by id: String) async -> DeviceAccount?
    func updateDevice(_ device: DeviceAccount) async -> Bool
    func deleteDevice(_ deviceID: String) async throws
    func getAllDevices() async -> [DeviceAccount]
}

class FirebaseManager {
    private lazy var db = Firestore.firestore()


    private var completionContinuation: CheckedContinuation<[Decodable], Error>?


}

// MARK: - Merchant Provider
extension FirebaseManager: MerchantProtocol {

    func createMerchant(_ merchant: Merchant) async -> Bool {
        await create(merchant, in: .merchants)
    }

    func getMerchant(by merchantID: String) async -> Merchant? {
        await getItemWithID(merchantID, in: .merchants)

    }

    func updateMerchant(_ merchant: Merchant) async -> Bool {
        guard let merchantID = merchant.id else { return false }
        return await updateItemWithID(merchantID,
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

    enum CollectionName: String {
        case merchants
        case devices
    }
}

// MARK: - Device Provider
extension FirebaseManager: DeviceProtocol {
    func saveDevice(_ device: DeviceAccount) async -> Bool {
        await create(device, in: .devices)
    }

    func getDevice(by id: String) async -> DeviceAccount? {
        await getItemWithID(id, in: .devices)
    }

    func updateDevice(_ device: DeviceAccount) async -> Bool {
        guard let deviceID = device.id else { return false }
        return await updateItemWithID(deviceID, content: device, in: .devices)
    }

    func deleteDevice(_ deviceID: String) async throws {
        try await deleteItemWithID(deviceID, in: .devices)
    }

    func getAllDevices() async -> [DeviceAccount] {
        return []
//        await getAll(in: .devices)
    }

}

// MARK: - Helper Methods
extension FirebaseManager {
    func create<T: Encodable>(_ element: T, in collection: CollectionName) async -> Bool {
        do {

            return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Bool, Error>) in
                do {
                    _ = try db.collection(collection.rawValue).addDocument(from: element) { error in

                        if let error {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume(returning: true)
                        }
                    }
                } catch {
                    debugPrint("Could not save \(type(of: element)): \(error.localizedDescription).")
                    continuation.resume(throwing: error)
                }
            }
        } catch {
            debugPrint("Error on saving \(type(of: element)): \(error.localizedDescription).")
            return false
        }
    }

    func getAll<T: Decodable>(in collection: CollectionName) async -> [T] {
        do {
            let querySnapshot = try await db.collection(collection.rawValue)
                .getDocuments()
            let result = querySnapshot.documents.compactMap { document -> T? in
                do {
                    return try document.data(as: T.self)
                } catch {
                    debugPrint("Firestore Decoding error: ", error, querySnapshot.documents.forEach { print($0.data()) } )
                    return nil
                }
            }
            return result
        } catch {
            debugPrint("Can not get \(type(of: Merchant.self)) Error: \(error).")
            return []
        }
    }

    func getItemWithID<T: Decodable>(_ itemID: String,
                                     in collection: CollectionName) async -> T? {
        do {
            let snapshot = try await db.collection(collection.rawValue)
                .document(itemID)
                .getDocument()

            let item = try snapshot.data(as: T.self)

            return item
        } catch {
            debugPrint("Error getting \(T.self): \(error)")
            return nil
        }
    }

    func deleteItemWithID(_ itemID: String,
                          in collection: CollectionName) async throws  {
        try await db.collection(collection.rawValue)
            .document(itemID)
            .delete()
    }

    func updateItemWithID<T: Encodable>(_ itemID: String,
                                        content: T,
                                        in collection: CollectionName) async -> Bool {
        return await withCheckedContinuation {
            (continuation: CheckedContinuation<Bool, Never>) in
            do {

                try db.collection(collection.rawValue)
                    .document(itemID)
                    .setData(from: content)

                continuation.resume(returning: true)
            } catch {
                debugPrint("Error updating Merchant: \(error)")
                continuation.resume(returning: false)
            }
        }
    }
}
