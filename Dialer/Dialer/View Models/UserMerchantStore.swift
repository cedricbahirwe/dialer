//
//  UserMerchantStore.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 11/04/2023.
//

import Foundation

final class UserMerchantStore: MerchantStore {
    
    override func getMerchants() async {
        guard let userId = DialerStorage.shared.getSavedDevice()?.deviceHash, !userId.isEmpty else { return }
        let sortedMerchants = await merchantProvider.getMerchantsFor(userId)
        setMerchants(to: sortedMerchants)
    }
}
