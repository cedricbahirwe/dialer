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



extension Contact {
    var initials: String {
        if names.isEmpty {
            return "···"
        } else {
            let names = names.split(separator: " ")
            if names.count >= 2 {
                let first = names[0].first!
                let second = names[1].first!
                
                return String(first) + String(second)
            } else if names.count == 1  {
                return names[0].count >= 1 ? String(names[0].first!) :  "···"
            } else {
                if let name = names.first {
                    return name.isEmpty ? "" : String(name.first!)
                    
                } else {
                    return "···"
                }
            }
        }
    }

}
