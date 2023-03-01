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

    init(_ id: String? = nil, name: String, address: String, code: String, location: GeoPoint) {
        self.id = id
        self.name = name
        self.address = address
        self.code = code
        self.location = location
        self.hashCode = UUID()
    }
}


#if DEBUG
extension Merchant {
    static let sample = [
        Merchant(Optional("JkSKq9QM4vrBjeZHpg4d"), name: "La gardienne", address: "12 KN 41St, Kigali", code: "004422", location: GeoPoint(latitude: -1.955892, longitude: 30.069853)),
        Merchant(Optional("eHJNvwKhbdB1sdV19F3P"), name: "Cedrics", address: "", code: "12345", location: GeoPoint(latitude: -1.952583, longitude: 30.105167)),
        Merchant(Optional("sLcVGrcUfNrNdgq8HJhn"), name: "Emilienne", address: "Gishushu", code: "028508", location: GeoPoint(latitude: -1.952583, longitude: 30.103861)),
        Merchant(Optional("xW5nAHmPgTmvyohe0XtI"), name: "La gardienne", address: "12 KN 41St, Kigali", code: "004422", location: GeoPoint(latitude: -1.955892, longitude: 30.069853))
    ]
}
#endif
