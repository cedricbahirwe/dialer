//
//  ContactsFetcher.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 10/06/2021.
//

import Foundation
import Contacts

private enum PhonePermission: Error {
    case emptyContacts, containerError
}

final class PhoneContacts: ObservableObject {
    static let shared  = PhoneContacts()
    @Published private var contacts: [Contact] = []

    private init() {
        Task {
            try? await PhoneContacts.getMtnContacts(requestIfNeeded: false)
        }
    }

    func getContact(for transaction: Transaction) -> String? {
        guard transaction.type == .client else { return nil }
        return contacts.first {
            $0.phoneNumbers.contains(transaction.number)
        }?.names
    }

    class private func getContacts(requestIfNeeded: Bool) async throws -> [CNContact] {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized: break;
        case .notDetermined:
            if requestIfNeeded {
                try await CNContactStore().requestAccess(for: .contacts)
            } else {
                return []
            }
        default:
            return []
        }
        let contactStore = CNContactStore()
        
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey,
            CNContactThumbnailImageDataKey] as [Any]
        
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            Log.debug("Error fetching containers")
            throw PhonePermission.containerError
        }
        
        var results: [CNContact] = []
        
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            do {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                results.append(contentsOf: containerResults)
            } catch {
                Log.debug("Error fetching unified containers")
                throw PhonePermission.emptyContacts
            }
        }
    
        return Array(Set(results))
    }

    @MainActor
    class func getMtnContacts(requestIfNeeded: Bool = true) async throws -> [Contact] {
        if !PhoneContacts.shared.contacts.isEmpty {
            return PhoneContacts.shared.contacts
        }

        var contacts: [CNContact] = []
        do {
            contacts = try await PhoneContacts.getContacts(requestIfNeeded: requestIfNeeded)
        } catch {
            Log.debug(error.localizedDescription)
            throw PhonePermission.emptyContacts
        }
        
        var resultingContactsSet: Set<Contact> = []

        for contact in contacts {
            if contact.phoneNumbers.count > 0  {
                let contactsPhoneNumbers = contact.phoneNumbers
                let mtnNumbersFormat = contactsPhoneNumbers.filter { $0.value.stringValue.isMtnNumber }
                
                var pureMtnNumbers = mtnNumbersFormat.compactMap { $0.value.value(forKey: "digits") as? String }
                pureMtnNumbers = pureMtnNumbers.map { $0.asMtnNumber() }
                if !pureMtnNumbers.isEmpty {
                    let newContact = Contact(
                        id: contact.identifier,
                        names: contact.givenName + " " +  contact.familyName,
                        phoneNumbers: pureMtnNumbers)
                    resultingContactsSet.insert(newContact)
                }
            }
        }

        let resultingContacts = Array(resultingContactsSet)
        PhoneContacts.shared.contacts = resultingContacts
        return resultingContacts
    }
}
