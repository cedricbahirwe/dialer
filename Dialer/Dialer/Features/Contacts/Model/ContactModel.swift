//
//  ContactModel.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 10/06/2021.
//

import Foundation

struct Contact: Identifiable {
    let id: String
    let names: String
    private(set) var phoneNumbers: [String]

    init(id: String = UUID().uuidString, names: String, phoneNumbers: [String]) {
        self.id = id
        self.names = names
        self.phoneNumbers = phoneNumbers
    }
}

extension Contact: Hashable {
    static func == (lhs: Contact, rhs: Contact) -> Bool {
        lhs.names == rhs.names && lhs.phoneNumbers == rhs.phoneNumbers
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(names)
        hasher.combine(phoneNumbers)
    }

    mutating func updatePhones(_ numbers: [String]) {
        phoneNumbers = numbers
    }
    static let empty = Contact(names: "", phoneNumbers: [])
}
