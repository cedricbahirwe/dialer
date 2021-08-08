//
//  SendingView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 10/06/2021.
//

import SwiftUI

struct SendingView: View {
    
    @State private var showContactPicker = false
    @State private var allContacts: [Contact] = []
    @State private var selectedContact: Contact = Contact(names: "", phoneNumbers: [])
    @State private var transaction: Transaction = Transaction(amount: "", number: "", type: .client)
    
    var body: some View {
        VStack {
            VStack(spacing: 20) {
                TextField("Enter Amount", text: $transaction.amount)
                    .keyboardType(.decimalPad)
                    .foregroundColor(.primary)
                    .padding()
                    .frame(height: 45)
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.primary, lineWidth: 0.5))
                    .font(.callout)
                VStack(spacing: 3) {
                    if transaction.type == .client {
                        Text(selectedContact.names).font(.caption).foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .animation(.default)
                    }
                    TextField(
                        transaction.type == .client ?
                            "Enter Receiver's number" :
                            "Enter Merchant Code"
                        , text: $transaction.number.onChange(handleNumberField))
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .keyboardType(.numberPad)
                        .foregroundColor(.primary)
                        .padding()
                        .frame(height: 45)
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.primary, lineWidth: 0.5))
                        .font(.callout)
                    if transaction.type == .merchant {
                        Text("The code should be a 5-6 digits number")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                if transaction.type == .client {
                    Button(action: {
                        allContacts = PhoneContacts.getMtnContacts()
                        showContactPicker.toggle()
                    }) {
                        HStack {
                            Image(systemName: "person.fill")
                            Text("Pick a Contact").bold().font(.footnote)
                        }
                        .font(Font.footnote.bold())
                        .frame(maxWidth: .infinity)
                        .frame(height: 45)
                        .background(Color.primary)
                        .cornerRadius(8)
                        .foregroundColor(Color(.systemBackground))
                    }
                    .sheet(isPresented: $showContactPicker) {
                        ContactsList(contacts: $allContacts, selection: $selectedContact.onChange(cleanPhoneNumber))
                    }
                }
                
                
                Button(action: transferMoney) {
                    Text("Submit")
                        .font(Font.footnote.bold())
                        .frame(maxWidth: .infinity)
                        .frame(height: 45)
                        .background(transaction.isValid ? Color.primary : .red)
                        .cornerRadius(8)
                        .foregroundColor(Color(.systemBackground))
                }
                .disabled(transaction.isValid == false)
                .opacity(transaction.isValid ? 1 : 0.6)
                
                Spacer()
            }
            .padding()
            
        }
        .background(Color(.systemBackground)
                        .onTapGesture(perform: hideKeyboard))
        .onAppear(perform: requestContacts)
        .navigationTitle("Transfer Money")
        .toolbar {
            Text(transaction.type == .client ? "Merchant pay" : "Send Money")
                .font(Font.system(size: 18, design: .rounded))
                .foregroundColor(.blue)
                .onTapGesture  {
                    withAnimation {
                        transaction.number = ""
                        transaction.type.toggle()
                    }
                }
        }
    }
    
    private func requestContacts() {
        #if !DEBUG
        allContacts = PhoneContacts.getMtnContacts()
        #endif
    }
    
    private func cleanPhoneNumber(_ value: Contact?) {
        guard let contact = value else { return }
        let firstNumber  = contact.phoneNumbers.first!
        transaction.number = firstNumber
    }
    
    private func transferMoney() {
        hideKeyboard()
        MainViewModel.performQuickDial(for: transaction.fullCode)
    }
    
    /// Create a validation for the  `Number` field value
    /// - Parameter value: the validated data
    private func handleNumberField(_ value: String) {
        if transaction.type == .merchant{
            transaction.number = String(value.prefix(6))
        } else {
            let matchedContacts = allContacts.filter({ $0.phoneNumbers.contains(value.lowercased())})
            if matchedContacts.isEmpty == false {
                selectedContact = matchedContacts.first!
            } else {
                selectedContact = .init(names: "", phoneNumbers: [])
            }
        }
    }
}

#if DEBUG
struct SendingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                SendingView()
            }
            
        }
    }
}
#endif

