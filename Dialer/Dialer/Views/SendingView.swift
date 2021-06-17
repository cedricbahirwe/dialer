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
    @State private var selectedContact: Contact = .init(names: "", phoneNumbers: [])
    @State private var transaction: Transaction = Transaction(amount: "", phoneNumber: "", type: .client)
    
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
                    TextField(
                        transaction.type == .client ?
                            "Enter Receiver's number" :
                            "Enter Merchant Code"
                        , text: $transaction.phoneNumber)
                        .keyboardType(.numberPad)
                        .textContentType(.telephoneNumber)
                        .foregroundColor(.primary)
                        .padding()
                        .frame(height: 45)
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.primary, lineWidth: 0.5))
                        .font(.callout)
                        .onChange(of: transaction.phoneNumber, perform: manageNumber)
                    
                    if transaction.type == .merchant {
                        Text("The code should be a 6-digits number")
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
                        ContactsList(allContacts: $allContacts, selectedContact: $selectedContact)
                    }
                }
                
                
                Button(action: transferMoney) {
                    Text("Submit")
                        .font(Font.footnote.bold())
                        .frame(maxWidth: .infinity)
                        .frame(height: 45)
                        .background(Color.primary)
                        .cornerRadius(8)
                        .foregroundColor(Color(.systemBackground))
                }
                
                Spacer()
            }
            .padding()
            
            
        }
        .onChange(of: selectedContact) {
            transaction.phoneNumber = $0.phoneNumbers.firstElement
        }
        .background(Color(.systemBackground)
                        .onTapGesture(perform: hideKeyboard))
        .navigationTitle("Transfer Money")
        .toolbar {
            Text(transaction.type == .client ? "Merchant pay" : "Send Money")
                .font(Font.system(size: 18, design: .rounded))
                .foregroundColor(.blue)
                .onTapGesture  {
                    withAnimation {
                        transaction.type.toggle()
                    }
                }
        }
    }
    
    private func transferMoney() {
        hideKeyboard()
        MainViewModel().performQuickDial(for: transaction.fullCode)
    }
    
    /// Create a validation of the Phone Number
    /// - Parameter value: the validated data
    private func manageNumber(_ value: String) {
        if transaction.type == .merchant{
            transaction.phoneNumber = String(value.prefix(6))
        } else {
            
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

