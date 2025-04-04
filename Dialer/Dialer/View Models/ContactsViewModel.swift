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

    @Published private(set) var selectedContact: Contact

    var onSelectContact: (Contact) -> Void

    var searchedContacts: [ContactsDictionary] {
        let contacts = contactsDict.flatMap(\.contacts).sorted(by: { $0.names < $1.names })
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

    init(_ contacts: [Contact], selection: Contact, onSelectContact: @escaping (Contact) -> Void) {
        self.contactsDict = ContactsDictionary.transform(contacts)
        self.selectedContact = selection
        self.onSelectContact = onSelectContact
    }

    func handleContactSelection(_ contact: Contact) {
        selectedContact = contact
        if contact.phoneNumbers.count == 1 {
            onSelectContact(selectedContact)
        } else {
            showPhoneNumberSelector.toggle()
        }
    }

    func managePhoneNumber(_ phone: String) {
        selectedContact.updatePhones([phone])
        onSelectContact(selectedContact)
    }
}
