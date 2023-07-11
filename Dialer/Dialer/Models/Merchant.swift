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
