//
//  ContactsList.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 13/06/2021.
//

import SwiftUI
struct ContactsList: View {
    @Binding var allContacts: [Contact]
    @Binding var selectedContact: Contact
    @State private var searchQuery: String = ""
    @State private var isEditing = false
    @State private var showNumberSelection: Bool = false
    @Environment(\.presentationMode) private var presentationMode
        
    
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
    }
    
    var body: some View {
        VStack(spacing: 8) {
            if isEditing == false {
                Text("Contacts List")
                    .font(.largeTitle)
                    .bold()
                    .transition(.move(edge: .top))
            }
            
            HStack {
                TextField("Search by name or phone ", text: $searchQuery)
                    .padding(7)
                    .padding(.horizontal, 25)
                    .background(Color(.tertiarySystemGroupedBackground))
                    .cornerRadius(8)
                    .overlay(
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 8)
                            
                            if isEditing {
                                Button(action: {
                                    searchQuery = ""
                                }) {
                                    Image(systemName: "multiply.circle.fill")
                                        .foregroundColor(.gray)
                                        .padding(.trailing, 8)
                                }
                            }
                        }
                    )
                    .onTapGesture {
                        withAnimation {
                            isEditing = true
                        }
                    }
                
                if isEditing {
                    Button(action: {
                        withAnimation {
                            isEditing = false
                            searchQuery = ""
                            hideKeyboard()
                        }
                        
                    }) {
                        Text("Cancel")
                    }
                    .padding(.trailing, 10)
                    .animation(.default)
                }
            }
            .padding(.horizontal, 10)
            
            List(resultedContacts) { contact in
                ContactRowView(contact: contact)
                    .onTapGesture {
                        manageContact(contact)
                        
                    }
            }
        }
        .padding(.top, 10)
        .actionSheet(isPresented: $showNumberSelection) {
            ActionSheet(title: Text("Phone Number."),
                        message: Text("Select one phone number to transfer"),
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
            presentationMode.wrappedValue.dismiss()
        } else {
            showNumberSelection.toggle()
        }
    }
    
    private func managePhoneNumber(_ phone: String) {
        selectedContact.updatePhones([phone])
        presentationMode.wrappedValue.dismiss()
    }
}

struct ContactsList_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            
            ContactsList(contacts: .constant([.example]), selection: .constant(.example))
            ContactRowView(contact: .example)
                .previewLayout(.fixed(width: 400, height: 100))
        }
    }
}

struct ContactRowView: View {
    let contact: Contact
    var body: some View {
        HStack {
            LinearGradient(gradient: Gradient(colors: [Color.primary, Color.secondary]), startPoint: .top, endPoint: .bottom)
                .frame(width: 70, height: 70)
                .clipShape(Circle())
                .overlay(
                    Text(String(contact.names.initials))
                        .textCase(.uppercase)
                        .foregroundColor(Color(.systemBackground))
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                )
            VStack(alignment: .leading) {
                Text(contact.names)
                    .font(.system(size: 18, weight: .semibold))
                ForEach(contact.phoneNumbers, id: \.self) { phoneNumber in
                    Text(phoneNumber)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        
    }
}

extension String {
    var initials: String {
        if isEmpty {
            return self
        } else {
            let names = split(separator: " ")
            if names.count > 1 {
                let first = names[0].first!
                let second = names[1].first!
                
                return String(first) + String(second)
            } else {
                return String(names.first!.first!)
            }
        }
    }
}
