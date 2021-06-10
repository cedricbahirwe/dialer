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
        
        print("The phone", transaction.phoneNumber.trimmingCharacters(in: .whitespaces))
        
        let defaultMomo = "*182*1*1*\(transaction.trailingCode)#"
        
        MainViewModel().performQuickDial(for: defaultMomo)
    }
}
extension View {
    func phoneNumberWithContryCode() -> [Contact] {
        var resultingContacts: [Contact] = []
        let contacts = PhoneContacts.getContacts()
        for contact in contacts {
            if contact.phoneNumbers.count > 0  {
                let contactPhoneNumbers = contact.phoneNumbers
                let mtnNumbers = contactPhoneNumbers.filter {
                    //                    $0.label != "" ||
                    $0.value.stringValue.hasPrefix("078") ||
                        $0.value.stringValue.hasPrefix("+250") ||
                        $0.value.stringValue.hasPrefix("250")
                }
                
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


struct ContactsList: View {
    @Binding var allContacts: [Contact]
    @Binding var selectedContact: Contact
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        VStack(spacing: 8) {
            Text("Contacts List")
                .font(.largeTitle).bold().padding(.top, 10)
            List(allContacts.sorted(by: { $0.names < $1.names })) { contact in
                ContactRowView(contact: contact)
                    .onTapGesture {
                        selectedContact = contact
                        presentationMode.wrappedValue.dismiss()
                    }
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
            
            //            ContactsList(allContacts: .constant(Contact.example), selectedContact: .constant(Contact.example[0]))
            //            ContactRowView(contact: Contact.example[0])
            //                .previewLayout(.fixed(width: 400, height: 100))
        }
    }
}
#endif

struct ContactRowView: View {
    let contact: Contact
    var body: some View {
        HStack {
            LinearGradient(gradient: Gradient(colors: [Color.red, Color.blue]), startPoint: .leading, endPoint: .bottomTrailing)
                .frame(width: 70, height: 70)
                .clipShape(Circle())
                .overlay(
                    Text(String(contact.names.prefix(3)))
                        .foregroundColor(.white)
                        .font(.title)
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
