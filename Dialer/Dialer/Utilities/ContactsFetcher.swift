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

final class PhoneContacts {
    
    private init() {}
    
    class private func getContacts() async throws -> [CNContact] {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized: break;
        case .notDetermined:
            try await CNContactStore().requestAccess(for: .contacts)
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
    
    class func getMtnContacts() async throws -> [Contact] {
        var contacts: [CNContact] = []
        do {
            contacts = try await PhoneContacts.getContacts()
        } catch {
            Log.debug(error.localizedDescription)
            throw PhonePermission.emptyContacts
        }
        
        var resultingContacts: [Contact] = []

        for contact in contacts {
            if contact.phoneNumbers.count > 0  {
                let contactsPhoneNumbers = contact.phoneNumbers
                let mtnNumbersFormat = contactsPhoneNumbers.filter { $0.value.stringValue.isMtnNumber }
                
                var pureMtnNumbers = mtnNumbersFormat.compactMap { $0.value.value(forKey: "digits") as? String }
                pureMtnNumbers = pureMtnNumbers.map { $0.asMtnNumber() }
                if pureMtnNumbers.isEmpty == false {
                    let newContact = Contact(names: contact.givenName + " " +  contact.familyName,
                                             phoneNumbers: pureMtnNumbers)
                    resultingContacts.append(newContact)
                }
            }
        }
        
        return resultingContacts
    }
}
