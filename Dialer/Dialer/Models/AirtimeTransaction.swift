//
//  PurchaseDetailModel.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 04/01/2022.
//

import Foundation

struct AirtimeTransaction: Hashable, Codable {
    var amount: Int = 0
    var purchaseDate: Date = .now

    private var prefixCode: String { "*182*2*1*1*1*" }
}

extension AirtimeTransaction {

    func getRedactedFullCode() -> String {
        return "\(prefixCode)\(amount)*PIN#"
    }

    func getFullUSSDCode() -> String {
        return "\(prefixCode)\(amount)#"
    }

    /// Used on the `PuchaseDetailView` to dial, save code, save pin.
    /// - Parameters:
    ///   - purchase: the purchase to take the fullCode from.
    func dialCode() async throws {
        let fullCode = getFullUSSDCode()
        if let telUrl = URL(string: "tel://\(fullCode)") {
            try await DialService.shared.dial(telUrl)
        } else {
            throw DialingError.canNotDial
        }
    }
}
