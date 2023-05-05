//
//  ContactsList.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 13/06/2021.
//

import SwiftUI
struct ContactsListView: View {
    @Binding var allContacts: [Contact]
    @Binding var selectedContact: Contact
    
    @State private var searchQuery: String = ""
    @State private var isEditing = false
    @State private var showNumberSelection: Bool = false
    @Environment(\.dismiss)
    private var dismiss
    
    private var resultedContacts: [Contact] {
        let contacts = allContacts.sorted(by: { $0.names < $1.names })
        if searchQuery.isEmpty {
            return contacts
        } else {
            return contacts.filter({ $0.names.lowercased().contains(searchQuery.lowercased())})
        }
    }
    
    init(contacts: Binding<[Contact]>, selection: Binding<Contact>) {
        _allContacts = contacts
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
                    .animation(.spring(), value: isEditing)
                searchBarView
            }
            .padding(.horizontal)
            .padding(.top, isEditing ? -50 : 0)

            List(resultedContacts) { contact in
                ContactRowView(contact: contact)
                    .onTapGesture {
                        manageContact(contact)
                    }
            }
        }
        .padding(.top, 10)
        .background(Color.primaryBackground)
        .actionSheet(isPresented: $showNumberSelection) {
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
            showNumberSelection.toggle()
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
                        self.isEditing = isEditing
                    }
                }
                .font(.system(.callout, design: .rounded))

                if isEditing {
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

            if isEditing {
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
            isEditing = false
        }
    }
}

#if DEBUG
struct ContactsList_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            
            ContactsListView(contacts: .constant([.example, .example, .example1, .example, .example]),
                         selection: .constant(.example))
            ContactsListView.ContactRowView(contact: .example)
                .padding()
                .previewLayout(.sizeThatFits)
        }
    }
}
#endif

extension ContactsListView {
    struct ContactRowView: View {
        let contact: Contact
        var body: some View {
            HStack {
                Text(contact.names)
                    .font(.system(.callout, design: .rounded).weight(.medium))
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    if contact.phoneNumbers.count == 1 {
                        Text(contact.phoneNumbers[0])
                    } else {
                        Text("\(Text(contact.phoneNumbers[0])), +\(contact.phoneNumbers.count-1)more")
                    }
                }
                .font(.system(.footnote, design: .rounded))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            
        }
    }
}
