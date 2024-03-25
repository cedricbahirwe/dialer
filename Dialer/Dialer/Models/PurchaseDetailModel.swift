//
//  PurchaseDetailModel.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 04/01/2022.
//

import Foundation
import UIKit

struct PurchaseDetailModel: Hashable, Codable {
    var amount: Int = 0
    var purchaseDate: Date = .now
    
    private var prefixCode: String { "*182*2*1*1*1*" }
}

extension PurchaseDetailModel {
    
    func getRedactedFullCode() -> String {
        return "\(prefixCode)\(amount)*PIN#"
    }
    
    @available(*, deprecated, renamed: "getFullUSSDCode()", message: "MTN disabled the ability to directly dial airtime USSD that includes Momo PIN.")
    private func getFullUSSDCode(with pinCode: CodePin?) -> String {
        let pin: String
        if let pinCode, pinCode.digits >= 5 {
            pin = pinCode.asString
        } else {
            pin = ""
        }
        
        /// `27/03/2023`: MTN disabled the ability to dial airtime USSD that includes Momo PIN for an amount greater than 99.
        /// You can dial the code with PIN for amount in the range of 10 to 99
        if !pin.isEmpty && AppConstants.allowedAmountRangeForPin.contains(amount) {
            return "\(prefixCode)\(amount)*\(pin)#"
        } else {
            return "\(prefixCode)\(amount)#"
        }
    }
    
    func getFullUSSDCode() -> String {
        return "\(prefixCode)\(amount)#"
    }
    
    
    /// Used on the `PuchaseDetailView` to dial, save code, save pin.
    /// - Parameters:
    ///   - purchase: the purchase to take the fullCode from.
    func dialCode() async throws {
        
        let newUrl = getFullUSSDCode()
        
        if let telUrl = URL(string: "tel://\(newUrl)") {
            try await DialService.dial(telUrl)
        } else {
            throw DialingError.canNotDial
        }
    }
}
