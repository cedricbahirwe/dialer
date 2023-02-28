//
//  Merchant.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 26/02/2023.
//

import SwiftUI
import FirebaseFirestoreSwift
import FirebaseFirestore

struct Merchant: Codable, Identifiable {
    @DocumentID var id: String?
    let name: String
    let address: String
    let code: String
    let location: GeoPoint
    var hashCode = UUID()

    init(name: String, address: String, code: String, lat: Double, long: Double) {
        self.name = name
        self.address = address
        self.code = code
        self.location = GeoPoint(latitude: lat, longitude: long)
        self.hashCode = UUID()
    }
}
