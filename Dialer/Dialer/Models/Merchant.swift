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
    let hashCode: UUID
    let createdDate: Date?
    
    init(_ id: String? = nil, name: String, address: String?, code: String, ownerId: String) {
        self.id = id
        self.name = name
        self.address = address
        self.code = code
        self.ownerId = ownerId
        self.hashCode = UUID()
        self.createdDate = Date()
    }
}


extension Merchant {
    /// This pattern is designed to match and capture the digits that come after *XXX*Y*Z* and before %23 in the input string.
    /// In the example input string tel://*182*8*1*029813%23, the regular expression matches the `029813`,
    /// which is what we want to extract.
    static func extractMerchantCode(from input: String) -> String? {
        do {
            // Define the regular expression pattern using backslashes to escape special characters.
            let pattern = "(?<=\\*\\d{3}\\*\\d\\*\\d\\*)(\\d+)(?=%23)"
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(location: 0, length: input.utf16.count)

            // Find the first match of the regular expression in the input string.
            if let match = regex.firstMatch(in: input, options: [], range: range) {
                
                // If a match is found, get the starting index of the digits within the input string.
                let startIndex = input.index(input.startIndex, offsetBy: match.range(at: 1).location)
                
                // Calculate the ending index of the digits within the input string.
                let endIndex = input.index(startIndex, offsetBy: match.range(at: 1).length)
                
                // Extract the matched digits from the input string using string slicing.
                return String(input[startIndex..<endIndex])
            }
        } catch {
            Tracker.shared.logError(error: error)
        }
        
        return nil
    }
}
