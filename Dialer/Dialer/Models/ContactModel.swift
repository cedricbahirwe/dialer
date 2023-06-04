//
//  ContactModel.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 10/06/2021.
//

import Foundation

struct Contact: Identifiable {
    var id: String { names + phoneNumbers.description }
    let names: String
    private(set) var phoneNumbers: [String]
    
    init(names: String, phoneNumbers: [String]) {
        self.names = names
        self.phoneNumbers = phoneNumbers
    }

    mutating func updatePhones(_ numbers: [String]) {
        phoneNumbers = numbers
    }
}
