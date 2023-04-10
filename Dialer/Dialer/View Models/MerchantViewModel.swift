//
//  MerchantViewModel.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 28/02/2023.
//

import CoreLocation

final class MerchantStore: ObservableObject {
    @Published private(set) var userMerchants: [Merchant] = []
    @Published private(set) var allMerchants: [Merchant] = []
    @Published private(set) var isFetching = false
    private let merchantProvider: MerchantProtocol

    init(_ merchantProvider: MerchantProtocol = FirebaseManager()) {
        self.merchantProvider = merchantProvider
        Task {
            await getAllMerchants()
            await getUserMerchants()
        }
    }

    /// Save a new Merchant
    /// - Parameter merchant: new merchant to be saved
    /// - Returns: Whether or not the merchant was saved
    func saveMerchant(_ merchant: Merchant) async -> Bool {
        startFetch()
        do {
            let isMerchantSaved = try await merchantProvider.createMerchant(merchant)
            
            stopFetch()
            await getAllMerchants()
            await getUserMerchants()
            return isMerchantSaved
        } catch {
            print("Could not save merchant: ", error)
            return false
        }
    }

    func deleteMerchants(at offsets: IndexSet) {
        guard let first = offsets.first else { return }
        let merchant = allMerchants[first]

        Task {
            await deleteMerchant(merchant, at: first)
        }
    }

    /// Delete a specific Merchant
    /// - Parameters:
    ///   - merchant: merchant to be deleted
    ///   - index: the index of the merchant element in the collection
    private func deleteMerchant(_ merchant: Merchant, at index: IndexSet.Element) async {
        guard let merchantID = merchant.id else { return }

        startFetch()
        DispatchQueue.main.async {
            self.allMerchants.remove(at: index)
        }

        do {
            try await merchantProvider.deleteMerchant(merchantID)
            stopFetch()
        } catch {
            stopFetch()
            DispatchQueue.main.async {
                self.allMerchants.insert(merchant, at: index)
            }
        }
    }


    /// Get All Merchants Available
    func getAllMerchants() async {
        startFetch()

        let result = await merchantProvider.getAllMerchants()

        stopFetch()
        DispatchQueue.main.async {
            self.allMerchants = result.sorted(by: { $0.name < $1.name })
        }
    }
    
    /// Get Filtered merchants near based of current user
    /// - Returns: Merchants sorted alphabetically
    @MainActor
    func getUserMerchants() async {
        guard let userId = DialerStorage.shared.getSavedDevice()?.deviceHash else { return }
        let sortedMerchants = await merchantProvider.getMerchantsFor(userId)
        userMerchants = sortedMerchants
    }

    func startFetch() {
        DispatchQueue.main.async {
            self.isFetching = true
        }
    }

    func stopFetch() {
        DispatchQueue.main.async {
            self.isFetching = false
        }
    }
}
