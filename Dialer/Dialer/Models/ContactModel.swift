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
    static let example = [Contact(names: "Kate Bell", phoneNumbers: ["(555) 564-8583", "(415) 555-3695"]), Contact(names: "Daniel Higgins", phoneNumbers: ["555-478-7672", "(408) 555-5270", "(408) 555-3514"]), Contact(names: "John Appleseed", phoneNumbers: ["888-555-5512", "888-555-1212"]), Contact(names: "Anna Haro", phoneNumbers: ["555-522-8243"]), Contact(names: "Hank Zakroff", phoneNumbers: ["(555) 766-4823", "(707) 555-1854"]), Contact(names: "David Taylor", phoneNumbers: ["555-610-6679"])]
}

