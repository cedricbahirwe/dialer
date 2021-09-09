//
//  ContactsFetcher.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 10/06/2021.
//

import Foundation
import Contacts

class PhoneContacts {
    
    private init() {}
    
    class private func getContacts() -> [CNContact] {
        
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized: break;
        default: return []
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
            print("Error fetching containers")
        }
        
        var results: [CNContact] = []
        
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            do {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                results.append(contentsOf: containerResults)
            } catch {
                print("Error fetching unified containers")
            }
        }
        return results
    }
    
    class public func getMtnContacts() -> [Contact] {
        var resultingContacts: [Contact] = []
        let contacts = PhoneContacts.getContacts()
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
