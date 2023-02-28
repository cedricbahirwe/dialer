//
//  MerchantViewModel.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 28/02/2023.
//

import FirebaseFirestore


final class MerchantStore: ObservableObject {
    @Published private(set) var merchants: [Merchant] = []
    @Published private(set) var isFetching = false

    private lazy var db = Firestore.firestore()

    func saveMerchant(_ merchant: Merchant) async -> Bool {
        do {
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

    func getAllMerchants() {
        isFetching = true
        db.collection("merchants")
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


enum Collection {
    static let merchants = "merchants"
}
}
