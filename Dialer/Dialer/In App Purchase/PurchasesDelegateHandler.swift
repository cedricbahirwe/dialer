//
//  PurchasesDelegateHandler.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 12/07/2023.
//

import Foundation
import RevenueCat

final class PurchasesDelegateHandler: NSObject, ObservableObject {
    static let shared  = PurchasesDelegateHandler()
}

extension PurchasesDelegateHandler: PurchasesDelegate {
    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        UserViewModel.shared.customerInfo = customerInfo
    }
}
