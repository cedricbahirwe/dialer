//
//  MeterNumber.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 04/01/2022.
//

import Foundation

struct MeterNumber: Identifiable, Codable {
    let id: UUID
    let value: String
    
    init(value: String) {
        self.id = UUID()
        self.value = value
    }
}
