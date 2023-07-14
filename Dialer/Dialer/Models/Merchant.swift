//
//  Merchant.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 26/02/2023.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

struct Merchant: Codable, Identifiable {
    @DocumentID var id: String?
    let name: String
    let address: String?
    let code: String
    let ownerId: String?
    var hashCode = UUID()
    var createdDate: Date? = Date()
    
    init(_ id: String? = nil, name: String, address: String?, code: String, ownerId: String, createdDate: Date = Date()) {
        self.id = id
        self.name = name
        self.address = address
        self.code = code
        self.ownerId = ownerId
        self.hashCode = UUID()
        self.createdDate = createdDate
    }
}


extension Merchant {
    static func extractMerchantCode(from urlString: String) -> String? {
        // Check if the URL string starts with the expected scheme
        guard urlString.hasPrefix("tel://*182*8*1*") else {
            return nil
        }
        
        // Remove the scheme and prefix from the URL string
        let prefixLength = "tel://*182*8*1*".count
        let codeStartIndex = urlString.index(urlString.startIndex, offsetBy: prefixLength)
        let codeEndIndex = urlString.index(before: urlString.endIndex)
        let codeRange = codeStartIndex...codeEndIndex
        let merchantCode = String(urlString[codeRange])
        
        // Remove any percent encoding and trailing character (%23)
        let decodedMerchantCode = merchantCode
            .replacingOccurrences(of: "%23", with: "")
            .removingPercentEncoding ?? merchantCode
        
        // Return the extracted merchant code
        return decodedMerchantCode
    }
}
