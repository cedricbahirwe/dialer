//
//  MerchantViewModel.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 28/02/2023.
//

import CoreLocation

@MainActor
class BaseViewModel: ObservableObject {
    @Published private(set) var isFetching = false

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

class MerchantStore: BaseViewModel {
    @Published private(set) var merchants: [Merchant]
    let merchantProvider: MerchantProtocol

    init(_ merchantProvider: MerchantProtocol = FirebaseManager()) {
        self.merchants = []
        self.merchantProvider = merchantProvider
        super.init()
        Task {
            await getMerchants()
        }
    }
    
    func setMerchants(to newMerchants: [Merchant]) {
        self.merchants = newMerchants
    }

    /// Save a new Merchant
    /// - Parameter merchant: new merchant to be saved
    /// - Returns: Whether or not the merchant was saved
    func saveMerchant(_ merchant: Merchant) async -> Bool {
        startFetch()
        do {
            let isMerchantSaved = try await merchantProvider.createMerchant(merchant)
            
            stopFetch()
            await getMerchants()
            return isMerchantSaved
        } catch {
            Tracker.shared.logError(error: error)
            Log.debug("Could not save merchant: ", error)
            stopFetch()
            return false
        }
    }

    /// Get All Merchants Available
    @MainActor
    func getMerchants() async {
        startFetch()

        let result = await merchantProvider.getAllMerchants()
        
        stopFetch()
        let sortedResult = result.sorted(by: { $0.name < $1.name })
        self.setMerchants(to: sortedResult)
    }
    
    /// Delete first selected Merchant
    func deleteMerchants(at offsets: IndexSet) {
        guard let first = offsets.first else { return }
        let merchant = merchants[first]

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
            self.merchants.remove(at: index)
        }

        do {
            try await merchantProvider.deleteMerchant(merchantID)
            stopFetch()
        } catch {
            stopFetch()
            DispatchQueue.main.async {
                self.merchants.insert(merchant, at: index)
            }
        }
    }
}
