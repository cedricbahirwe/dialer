//
//  ContactsDictionary.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 01/10/2025.
//  Copyright © 2025 Cédric Bahirwe. All rights reserved.
//
import Foundation

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
