//
//  ContactModel.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 10/06/2021.
//

import Foundation

struct Contact: Identifiable {
    let id = UUID()
    let names: String
    private(set) var phoneNumbers: [String]
    
    init(names: String, phoneNumbers: [String]) {
        self.names = names
        self.phoneNumbers = phoneNumbers
    }
    
    mutating func updatePhones(_ numbers: [String]) {
        phoneNumbers = numbers
    }
    static let empty = Contact(names: "", phoneNumbers: [])
}

struct ContactsDictionary: Identifiable {
    var id: Character { letter }
    let letter: Character
    let contacts: [Contact]
}

extension ContactsDictionary {
    static func transform(_ contacts: [Contact]) -> [ContactsDictionary] {
        let contactsDictionary = Dictionary(grouping: contacts) { contact in
            contact.names.prefix(1).uppercased().first ?? Character(" ")
        }.map { (letter, contacts) in
            Self(letter: letter, contacts: contacts)
        }
        
        return contactsDictionary.sorted { $0.letter < $1.letter }
    }
}
