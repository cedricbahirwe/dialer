//
//  UserMerchantStore.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 11/04/2023.
//

import Foundation

final class UserMerchantStore: MerchantStore {

    override func getMerchants() async {
        guard let userId = DialerStorage.shared.getSavedDevice()?.deviceHash, !userId.uuidString.isEmpty else { return }
        let sortedMerchants = await merchantProvider.getMerchantsFor(userId)
        setMerchants(to: sortedMerchants)
    }

    func deleteAllUserMerchants() async {
        guard let userId = DialerStorage.shared.getSavedDevice()?.deviceHash, !userId.uuidString.isEmpty else { return }
        do {
            _ = try await merchantProvider.deleteAllUsersMerchants(userId)
            setMerchants(to: [])
        } catch {
            Log.debug("Failed to delete user merchants: \(error.localizedDescription)")
        }
    }

    func firstMatchingMerchantCode(_ merchantCode: String) -> Merchant? {
        merchants.first { $0.code == merchantCode }
    }
}
