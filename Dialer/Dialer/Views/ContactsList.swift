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
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        VStack(spacing: 8) {
            Text("Contacts List")
                .font(.largeTitle).bold().padding(.top, 10)
            HStack {
                
                TextField("Search ...", text: $searchQuery)
                    .padding(7)
                    .padding(.horizontal, 25)
                    .background(Color(.systemGray6))
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
                    .padding(.horizontal, 10)
                    .onTapGesture {
                        self.isEditing = true
                    }
                
                if isEditing {
                    Button(action: {
                        isEditing = false
                        searchQuery = ""
                        hideKeyboard()
                        
                    }) {
                        Text("Cancel")
                    }
                    .padding(.trailing, 10)
                    .transition(.move(edge: .trailing))
                    .animation(.default)
                }
            }
            
            List(allContacts.sorted(by: { $0.names < $1.names })) { contact in
                ContactRowView(contact: contact)
                    .onTapGesture {
                        selectedContact = contact
                        presentationMode.wrappedValue.dismiss()
                    }
            }
        }
    }
    
    var resulsts: [Contact] {
        let contacts = allContacts.sorted(by: { $0.names < $1.names })
        if searchQuery.isEmpty {
            return contacts
        } else {
            return contacts.filter({ $0.names.lowercased().contains(searchQuery.lowercased())})
        }
    }
}

struct ContactsList_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            
            ContactsList(allContacts: .constant(Contact.example), selectedContact: .constant(Contact.example[0]))
            ContactRowView(contact: Contact.example[0])
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
