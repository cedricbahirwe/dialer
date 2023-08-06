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
    
    func getFullUSSDCode(with pinCode: CodePin?) -> String {
        let pin: String
        if let pinCode, pinCode.digits >= 5 {
            pin = pinCode.asString
        } else {
            pin = ""
        }
        
        /// `27/03/2023`: MTN disabled the ability to dial airtime USSD that includes Momo PIN for an amount greater than 99.
        /// You can dial the code with PIN for amount in the range of 10 to 99
        if AppConstants.allowedAmountRangeForPin.contains(amount) && !pin.isEmpty {
            return "\(prefixCode)\(amount)*\(pin)#"
        } else {
            return "\(prefixCode)\(amount)#"
        }
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
