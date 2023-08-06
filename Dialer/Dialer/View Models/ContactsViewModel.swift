//
//  ContactsViewModel.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 14/07/2023.
//

import Foundation

final class ContactsViewModel: ObservableObject {
    @Published var searchQuery = ""
    
    @Published var showPhoneNumberSelector: Bool = false
    
    private let contactsDict: [ContactsDictionary]
    
    var contacts: [Contact] {
        contactsDict.flatMap(\.contacts)
    }
    
    @Published private(set) var selectedContact: Contact
    
    var completion: (Contact) -> Void
    
    
    var searchedContacts: [ContactsDictionary] {
        let contacts = contacts.sorted(by: { $0.names < $1.names })
        if searchQuery.isEmpty {
            return contactsDict
        } else {
            let filteredContacts = contacts.filter { contact in
                contact.names.range(of: searchQuery, options: [.caseInsensitive, .diacriticInsensitive]) != nil ||
                contact.phoneNumbers.reduce("", +).contains(searchQuery)
            }
            
            return ContactsDictionary.transform(filteredContacts)
        }
    }
    
    init(_ contacts: [Contact], selection: Contact, completion: @escaping (Contact) -> Void) {
        self.contactsDict = ContactsDictionary.transform(contacts)
        self.selectedContact = selection
        self.completion = completion
    }
    
    
    
    func handleSelection(_ contact: Contact) {
        selectedContact = contact
        if contact.phoneNumbers.count == 1 {
            completion(selectedContact)
        } else {
            showPhoneNumberSelector.toggle()
        }
    }
    
    func managePhoneNumber(_ phone: String) {
        selectedContact.updatePhones([phone])
        completion(selectedContact)
    }
    
}
