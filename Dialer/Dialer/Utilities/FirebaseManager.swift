//
//  FirebaseManager.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 26/02/2023.
//

import Foundation

protocol MerchantProtocol {
    func createMerchant(_ merchant: Merchant)
    func getMerchant(by id: UUID) -> Merchant?
    func getAllMerchants() -> [Merchant]
    func getMerchantsNear(lat: Double, long: Double) -> [Merchant]
}

final class FirebaseManager: MerchantProtocol {

    func createMerchant(_ merchant: Merchant) {}

    func getMerchant(by id: UUID) -> Merchant? {
        nil
    }

    func getAllMerchants() -> [Merchant] {
        return []
    }

    func getMerchantsNear(lat: Double, long: Double) -> [Merchant] {
        return []
    }
}
