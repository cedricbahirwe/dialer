//
//  ContactModel.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 10/06/2021.
//

import Foundation

enum ContactsFilter {
    case none
    case mail
    case message
}

struct Contact: Identifiable, Equatable {
    var id = UUID()
    var names: String
    var phoneNumbers: [String]
    static let example = Contact(names: "Kate Bell", phoneNumbers: ["(555) 564-8583", "(415) 555-3695"])
}

