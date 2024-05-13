//
//  ContactsList.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 13/06/2021.
//

import SwiftUI

struct ContactsListView: View {
    @StateObject private var contactsVM: ContactsViewModel
    @FocusState private var isSearching: Bool
    
    init(contacts: [Contact],
         selection: Contact,
         completion: @escaping (Contact) -> Void) {
        self._contactsVM = StateObject(wrappedValue: ContactsViewModel(contacts, selection: selection, completion: completion))
        UITableView.appearance().backgroundColor = UIColor.primaryBackground
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                searchBarView
                
                if contactsVM.searchedContacts.isEmpty {
                    emptyResultsView
                } else {
                    
                    List {
                        ForEach(contactsVM.searchedContacts) { section in
                            Section(String(section.letter)) {
                                ForEach(section.contacts) { contact in
                                    ContactRowView(contact: contact)
                                        .onTapGesture {
                                            contactsVM.handleSelection(contact)
                                        }
                                }
                            }
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
                        Image(systemName: "chevron.down")
                            .font(.system(size: 18, design: .rounded))
                            .foregroundStyle(.blue)
                            .padding(5)
                    }
                }
            }
            .actionSheet(isPresented: $contactsVM.showPhoneNumberSelector) {
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
        var buttons: [ActionSheet.Button] = contactsVM.selectedContact.phoneNumbers.map({
            phoneNumber in
                .default(Text(phoneNumber)) { contactsVM.managePhoneNumber(phoneNumber)
                }
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
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
        }
        .frame(maxHeight: .infinity)
    }
    
    
}

private extension ContactsListView {
    var searchBarView: some View {
        HStack {
            HStack(spacing: 2) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                    .padding(9)
                
                TextField("Search by name or phone", text: $contactsVM.searchQuery) { isEditing in
                    withAnimation {
                        self.isSearching = isEditing
                    }
                }
                .font(.system(.callout, design: .rounded))
                .focused($isSearching)
                .submitLabel(.done)
                
                if isSearching {
                    Button(action: clearSearch) {
                        Image(systemName: "multiply.circle.fill")
                            .foregroundStyle(.secondary)
                            .padding(.trailing, 9)
                    }
                }
            }
            .background(Color.offBackground)
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
    
    private func clearSearch() {
        withAnimation {
            if contactsVM.searchQuery.isEmpty {
                endEditing()
            } else {
                contactsVM.searchQuery = ""
            }
        }
        
    }
    
    private func endEditing() {
        withAnimation {
            contactsVM.searchQuery = ""
            isSearching = false
            hideKeyboard()
        }
    }
}

#Preview {
    ContactsListView(
        contacts: [
            MockPreviewData.contact1,
            MockPreviewData.contact2
        ],
        selection: MockPreviewData.contact1
    ) { _ in }
}
