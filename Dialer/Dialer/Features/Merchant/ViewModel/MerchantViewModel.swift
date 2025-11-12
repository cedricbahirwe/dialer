//
//  MerchantViewModel.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 28/02/2023.
//

import Foundation
import Combine

class MerchantStore: BaseViewModel {
    @Published private(set) var merchants: [Merchant]
    let merchantProvider: MerchantProtocol

    // This code is received from a pending transaction
    private var potentMerchantCode: MerchantCreationModel?
    let savedMerchantPublisher = PassthroughSubject<Merchant, Never>()

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
    func saveMerchant(_ merchant: Merchant) async throws {
        try canSaveMerchant(merchant)
        startFetch()
        do {
            try await merchantProvider.createMerchant(merchant)
            stopFetch()
            savedMerchantPublisher.send(merchant)
            await getMerchants()
        } catch {
            stopFetch()
            Tracker.shared.logError(error: error)
            Log.debug("Could not save merchant: ", error)
            throw error
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

    func canSaveMerchant(_ newMerchant: Merchant) throws {
        for merchant in merchants {
            try validateMerchantName(merchant, newMerchant)
            try validateMerchantCode(merchant, newMerchant)

        }

        func validateMerchantName(_ existingMerchant: Merchant, _ newMerchant: Merchant) throws {
            if existingMerchant.name.trimmingCharacters(in: .whitespacesAndNewlines).contains(newMerchant.name.trimmingCharacters(in: .whitespacesAndNewlines)) {
                throw MerchantCreationModel.Error.invalidInput("You’ve already saved a merchant with this name.")
            }
        }

        func validateMerchantCode(_ existingMerchant: Merchant, _ newMerchant: Merchant) throws {
            if existingMerchant.code.trimmingCharacters(in: .whitespacesAndNewlines).contains(newMerchant.code.trimmingCharacters(in: .whitespacesAndNewlines)) {
                throw MerchantCreationModel.Error.invalidInput("You’ve already saved a merchant with this code.")
            }
        }
    }


    func storePotentialMerchantCode(_ merchantCode: String) {
        if merchants.contains(where: { $0.code == merchantCode }) {
            potentMerchantCode = nil
        } else {
            potentMerchantCode = MerchantCreationModel(code: merchantCode)
        }
    }

    func getPotentialMerchantCode() -> MerchantCreationModel? {
        return potentMerchantCode
    }


}
