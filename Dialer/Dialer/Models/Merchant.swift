//
//  Merchant.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 26/02/2023.
//

import SwiftUI

struct Merchant: Codable {
    let id: UUID
    let name: String
    let address: String
    let merchant: Int
    let latitude: Double
    let longitude: Double
}
