//
//  ContactModel.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 10/06/2021.
//

import Foundation

struct Contact: Identifiable, Equatable {
    let id = UUID()
    let names: String
    private(set) var phoneNumbers: [String]
    
    init(names: String, phoneNumbers: [String]) {
        self.names = names
        self.phoneNumbers = phoneNumbers
    }
    
    init(firstName: String,
         lastName: String,
         phoneNumbers: [String]) {
        
        names = "\(firstName) \(lastName)"
        self.phoneNumbers = phoneNumbers
    }
    
    
    
    mutating func updatePhones(_ numbers: [String]) {
        phoneNumbers = numbers
    }
    static let example = Contact(names: "Kate Bell",
                                 phoneNumbers: ["(555) 564-8583", "(415) 555-3695"])
}

