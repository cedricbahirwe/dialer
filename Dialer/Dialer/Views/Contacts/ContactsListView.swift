//
//  ContactsList.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 13/06/2021.
//

import SwiftUI

struct ContactsListView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let contacts: [Contact]
    @Binding var selectedContact: Contact
    
    @State private var searchQuery = ""
    @State private var isSearching = false
    @State private var showPhoneNumberSelector: Bool = false
    
    private var resultedContacts: [Contact] {
        let contacts = contacts.sorted(by: { $0.names < $1.names })
        if searchQuery.isEmpty {
            return contacts
        } else {
            return contacts.filter({ $0.names.lowercased().contains(searchQuery.lowercased())})
        }
    }
    
    init(contacts: [Contact], selection: Binding<Contact>) {
        self.contacts = contacts
        _selectedContact = selection
        UITableView.appearance().backgroundColor = UIColor.primaryBackground
    }
    
    var body: some View {
        VStack {

            VStack(alignment: .leading) {
                Text("Contacts List")
                    .font(.system(.title2, design: .rounded).bold())
                    .padding(.top)

                    .transition(.move(edge: .top))
                    .animation(.spring(), value: isSearching)
                searchBarView
            }
            .padding(.horizontal)
            .padding(.top, isSearching ? -50 : 0)

            List(resultedContacts) { contact in
                ContactRowView(contact: contact)
                    .onTapGesture {
                        manageContact(contact)
                    }
            }
        }
        .padding(.top, 10)
        .background(Color.primaryBackground)
        .actionSheet(isPresented: $showPhoneNumberSelector) {
            ActionSheet(title: Text("Phone Number."),
                        message: Text("Select a phone number to send to"),
                        buttons: alertButtons)
        }
    }
    private var alertButtons: [ActionSheet.Button] {
        var buttons: [ActionSheet.Button] = selectedContact.phoneNumbers.map({ phoneNumber in
                .default(Text(phoneNumber)) { managePhoneNumber(phoneNumber) }
        })
        buttons.append(.cancel())
        return buttons
    }
    private func manageContact(_ contact: Contact) {
        selectedContact = contact
        if contact.phoneNumbers.count == 1 {
            dismiss()
        } else {
            showPhoneNumberSelector.toggle()
        }
    }
    
    private func managePhoneNumber(_ phone: String) {
        selectedContact.updatePhones([phone])
        dismiss()
    }
}

private extension ContactsListView {
    var searchBarView: some View {
        HStack {
            HStack(spacing: 2) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .padding(9)

                TextField("Search name or phone", text: $searchQuery) { isEditing in
                    withAnimation {
                        self.isSearching = isEditing
                    }
                }
                .font(.system(.callout, design: .rounded))

                if isSearching {
                    Button(action: {
                        withAnimation {
                            if searchQuery.isEmpty {
                                endEditing()
                            } else {
                                searchQuery = ""
                            }
                        }

                    }) {
                        Image(systemName: "multiply.circle.fill")
                            .foregroundColor(.secondary)
                            .padding(.trailing, 9)
                    }
                }
            }
            .background(Color("offBackground"))
            .cornerRadius(6)

            if isSearching {
                Button(action: endEditing) {
                    Text("Cancel")
                        .font(.system(.body, design: .rounded))
                }
                .padding(.trailing, 10)
            }
        }
    }


    private func endEditing() {
        hideKeyboard()
        withAnimation {
            searchQuery = ""
            isSearching = false
        }
    }
}

#if DEBUG
struct ContactsList_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContactsListView(contacts: [MockPreview.contact1, MockPreview.contact2],
                             selection: .constant(MockPreview.contact1))
        }
    }
}
#endif
