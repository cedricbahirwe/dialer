//
//  MerchantViewModel.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 28/02/2023.
//

import FirebaseFirestore
import CoreLocation


final class MerchantStore: ObservableObject {
    @Published private(set) var merchants: [Merchant] = []
    @Published private(set) var isFetching = false

    private lazy var db = Firestore.firestore()

    func saveMerchant(_ merchant: Merchant) async -> Bool {
        do {
            isFetching = true
            
            return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Bool, Error>) in
                do {
                    _ = try db.collection(Collection.merchants).addDocument(from: merchant) { error in
                        DispatchQueue.main.async {
                            self.isFetching = false
                        }
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

    func deleteMerchants(at offsets: IndexSet) {
        guard let first = offsets.first else { return }
        let merchant = merchants[first]

        Task {
            await deleteMerchant(merchant, at: first)
        }
    }

    private func deleteMerchant(_ merchant: Merchant, at index: IndexSet.Element) async {
        guard let merchantID = merchant.id else { return }
        
        DispatchQueue.main.async {
            self.isFetching = true
            self.merchants.remove(at: index)
        }
        do {
            try await db.collection(Collection.merchants)
                .document(merchantID)
                .delete()
            DispatchQueue.main.async {
                self.isFetching = false
            }
        } catch {
            DispatchQueue.main.async {
                self.merchants.insert(merchant, at: index)
                self.isFetching = false
            }
        }
    }

    func getAllMerchants() {
        isFetching = true
        db.collection(Collection.merchants)
//            .order
        //            .order(by: "createdDate", descending: false)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    debugPrint("Firestore error: \(error).")
                    return
                }

                DispatchQueue.main.async {
                    self.isFetching = false
                }

                if let querySnapshot = querySnapshot {
                    let result = querySnapshot.documents.compactMap { document -> Merchant? in
                        do {
                            let res = try document.data(as: Merchant.self)
                            debugPrint("Complete", res)
                            return res
                        } catch {
                            debugPrint("Firestore Decoding error: ", error, querySnapshot.documents.forEach { print($0.data()) } )
                            return nil
                        }
                    }

                    DispatchQueue.main.async {
                        self.merchants = result
                    }
                }
            }
    }

    func getNearbyMerchants(_ userLocation: UserLocation) -> [Merchant] {
        let userLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let sortedMerchants = merchants.sorted {
            let location1 = CLLocation(latitude: $0.location.latitude, longitude: $0.location.longitude)
            let location2 = CLLocation(latitude: $1.location.latitude, longitude: $1.location.longitude)
            return userLocation.distance(from: location1) < userLocation.distance(from: location2)
        }
        return sortedMerchants
    }

    enum Collection {
        static let merchants = "merchants"
    }
}
