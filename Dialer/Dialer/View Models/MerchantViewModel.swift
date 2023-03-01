//
//  MerchantViewModel.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 28/02/2023.
//

import CoreLocation

final class MerchantStore: ObservableObject {
    @Published private(set) var merchants: [Merchant] = []
    @Published private(set) var isFetching = false
    private let merchantProvider: MerchantProtocol

    init(_ merchantProvider: MerchantProtocol = FirebaseManager()) {
        self.merchantProvider = merchantProvider
        Task {
            await getAllMerchants()
        }
    }


    /// Save a new Merchant
    /// - Parameter merchant: new merchant to be saved
    /// - Returns: Whether or not the merchant was saved
    func saveMerchant(_ merchant: Merchant) async -> Bool {
        isFetching = true
        let isMerchantSaved = await merchantProvider.createMerchant(merchant)

        isFetching = false

        return isMerchantSaved
    }

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
        
        DispatchQueue.main.async {
            self.isFetching = true
            self.merchants.remove(at: index)
        }

        do {
            try await merchantProvider.deleteMerchant(merchantID)
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


    /// Get All Merchants Available
    func getAllMerchants() async {
        isFetching = true

        let result = await merchantProvider.getAllMerchants()

        DispatchQueue.main.async {
            self.isFetching = false
            self.merchants = result
        }
    }

    /// Get Filtered merchants near user's location
    /// - Parameter userLocation: the current user's location
    /// - Returns: Merchants sorted by their distance to the user
    func getNearbyMerchants(_ userLocation: UserLocation) -> [Merchant] {
        let userLocation = CLLocation(latitude: userLocation.latitude,
                                      longitude: userLocation.longitude)

        let sortedMerchants = merchants.sorted {
            let location1 = CLLocation(latitude: $0.location.latitude, longitude: $0.location.longitude)
            let location2 = CLLocation(latitude: $1.location.latitude, longitude: $1.location.longitude)
            return userLocation.distance(from: location1) < userLocation.distance(from: location2)
        }
        return sortedMerchants
    }
}
