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
    var fullCode: String { "\(prefixCode)\(amount)*PIN#" }
    
    private var prefixCode: String { "*182*2*1*1*1*" }
}

extension PurchaseDetailModel {
    func getDialCode(pin: String) -> String {
        /// `27/03/2023`: MTN disabled the ability to dial airtime USSD that includes Momo PIN for an amount greater than 100.
        if amount > 100 || pin.isEmpty {
            return "\(prefixCode)\(amount)#"
        } else {
            return "\(prefixCode)\(amount)*\(pin)#"
        }
    }
    
    func getFullUSSDCode(with pinCode: CodePin?) -> String {
        let code: String
        if let pinCode, pinCode.digits >= 5 {
            code = pinCode.asString
        } else {
            code = ""
        }
        return getDialCode(pin: code)

    }
    
    
    /// Used on the `PuchaseDetailView` to dial, save code, save pin.
    /// - Parameters:
    ///   - purchase: the purchase to take the fullCode from.
    func dialCode(pinCode: CodePin? = nil) async throws {
        
        let newUrl = getFullUSSDCode(with: pinCode)
        
        if let telUrl = URL(string: "tel://\(newUrl)"),
           await UIApplication.shared.canOpenURL(telUrl) {
            let isCompleted = await UIApplication.shared.open(telUrl)
            if !isCompleted {
                throw DialingError.canNotDial
            }
        } else {
            throw DialingError.canNotDial
        }
    }
}
