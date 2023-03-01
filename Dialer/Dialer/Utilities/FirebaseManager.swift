//
//  FirebaseManager.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 26/02/2023.
//

import Foundation
import FirebaseFirestore

protocol MerchantProtocol {
    func createMerchant(_ merchant: Merchant) async -> Bool
    func getMerchant(by id: UUID) -> Merchant?
    func deleteMerchant(_ merchantID: String) async throws
    func getAllMerchants() async -> [Merchant]
    func getMerchantsNear(lat: Double, long: Double) -> [Merchant]
}

final class FirebaseManager: MerchantProtocol {
    private lazy var db = Firestore.firestore()

    func createMerchant(_ merchant: Merchant) async -> Bool {
        do {

            return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Bool, Error>) in
                do {
                    _ = try db.collection(Collection.merchants).addDocument(from: merchant) { error in

                        if let error {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume(returning: true)
                        }
                    }
                } catch {
                    debugPrint("Could not save merchant: \(error.localizedDescription).")
                    continuation.resume(throwing: error)
                }
            }
        } catch {
            debugPrint("Could not save merchant: \(error.localizedDescription).")
            return false
        }
    }

    func getMerchant(by id: UUID) -> Merchant? {
        nil
    }

    func deleteMerchant(_ merchantID: String) async throws {
        try await db.collection(Collection.merchants)
            .document(merchantID)
            .delete()
    }

    func getAllMerchants() async -> [Merchant] {
        do {
            return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[Merchant], Error>) in
                db.collection(Collection.merchants)
                    .addSnapshotListener { querySnapshot, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                            return
                        }

                        if let querySnapshot = querySnapshot {
                            let result = querySnapshot.documents.compactMap { document -> Merchant? in
                                do {
                                    return try document.data(as: Merchant.self)
                                } catch {
                                    debugPrint("Firestore Decoding error: ", error, querySnapshot.documents.forEach { print($0.data()) } )
                                    return nil
                                }
                            }

                            continuation.resume(returning: result)
                        }
                    }
            }
        } catch {
            debugPrint("Firestore Merchant Error: \(error).")
            return []
        }
    }

    func getMerchantsNear(lat: Double, long: Double) -> [Merchant] {
        return []
    }


    enum Collection {
        static let merchants = "merchants"
    }
}

// MARK: - Merchant Side
//extension MerchantStore {
//    func getNearbyMerchants() async -> [Merchant] {
//        guard let location = getLastKnownLocation() else { return [] }
//        return merchantProvider.getMerchantsNear(
//            lat: location.latitude,
//            long: location.longitude)
//    }
//}
