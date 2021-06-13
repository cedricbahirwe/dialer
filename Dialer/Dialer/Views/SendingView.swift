//
//  SendingView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 10/06/2021.
//

import SwiftUI

enum Transactiontype {
    case client, merchant
    
    mutating func toggle() {
        self = self == .client ? .merchant : .client
    }
}

struct Transaction: Identifiable {
    let id = UUID()
    var amount: String
    var phoneNumber: String
    var type: Transactiontype
    var date: Date { Date() }
    
    var trailingCode: String {
        // Need strategy to deal with country code
        phoneNumber.replacingOccurrences(of: " ", with: "") + "*" + String(amount)
    }
    
    
    
    var fullCode: String {
        if type == .client {
            return "*182*1*1*\(trailingCode)#"
        } else {
            return "*182*8*1*\(trailingCode)#"
        }
    }
}
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
                
                if transaction.type == .client {
                    Button(action: {
                        allContacts = phoneNumberWithContryCode()
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
}
extension View {
    func phoneNumberWithContryCode() -> [Contact] {
        var resultingContacts: [Contact] = []
        let contacts = PhoneContacts.getContacts()
        for contact in contacts {
            if contact.phoneNumbers.count > 0  {
                let contactPhoneNumbers = contact.phoneNumbers
                let mtnNumbers = contactPhoneNumbers.filter { $0.value.stringValue.isMtnNumber }
                
                let numbers = mtnNumbers.compactMap { $0.value.value(forKey: "digits") as? String }
                if mtnNumbers.isEmpty == false {
                    let newContact = Contact(names:contact.givenName + " " +  contact.familyName,phoneNumbers: numbers)
                    resultingContacts.append(newContact)
                }
            }
        }
        return resultingContacts
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

