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
    @FocusState private var isSearching: Bool
    @State private var showPhoneNumberSelector: Bool = false
    
    private var resultedContacts: [Contact] {
        let contacts = contacts.sorted(by: { $0.names < $1.names })
        if searchQuery.isEmpty {
            return contacts
        } else {
            return contacts.filter {
                $0.names.range(of: searchQuery, options: [.caseInsensitive, .diacriticInsensitive]) != nil ||
                $0.phoneNumbers.reduce("", +).contains(searchQuery)
            }
        }
    }
    
    init(contacts: [Contact], selection: Binding<Contact>) {
        self.contacts = contacts
        _selectedContact = selection
        UITableView.appearance().backgroundColor = UIColor.primaryBackground
    }
    
    var body: some View {
        NavigationView {
        VStack {
            searchBarView
            
            if resultedContacts.isEmpty {
                emptyResultsView
            } else {
                List(resultedContacts) { contact in
                    ContactRowView(contact: contact)
                        .onTapGesture {
                            manageContact(contact)
                        }
                }
            }
        }
        .padding(.top, 10)
        .background(Color.primaryBackground)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                
                Button(action: {
                    isSearching = false
                }) {
                    Text("Search")
                        .font(.system(size: 18, design: .rounded))
                        .foregroundColor(.blue)
                        .padding(5)
                }
            }
        }
        .actionSheet(isPresented: $showPhoneNumberSelector) {
            ActionSheet(title: Text("Phone Number."),
                        message: Text("Select a phone number to send to"),
                        buttons: alertButtons)
        }
        .onAppear() {
            DispatchQueue.main.asyncAfter(deadline: .now() ) {
                withAnimation {
                    isSearching = true
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    }
    private var alertButtons: [ActionSheet.Button] {
        var buttons: [ActionSheet.Button] = selectedContact.phoneNumbers.map({ phoneNumber in
                .default(Text(phoneNumber)) { managePhoneNumber(phoneNumber) }
        })
        buttons.append(.cancel())
        return buttons
    }
    
    private var emptyResultsView: some View {
        VStack(spacing: 8) {
            Image(systemName: "magnifyingglass.circle")
                .resizable()
                .frame(width: 100, height: 100)
            
            Text("No Results found")
                .font(.title2)
            Text("Try a different name or\nphone number")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
        }
        .frame(maxHeight: .infinity)
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

                TextField("Search by name or phone", text: $searchQuery) { isEditing in
                    withAnimation {
                        self.isSearching = isEditing
                    }
                }
                .font(.system(.callout, design: .rounded))
                .focused($isSearching)
                .submitLabel(.done)

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
            }
        }
        .animation(.default, value: isSearching)
        .padding(.horizontal)
    }

    private func endEditing() {
        withAnimation {
            searchQuery = ""
            isSearching = false
            hideKeyboard()
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
