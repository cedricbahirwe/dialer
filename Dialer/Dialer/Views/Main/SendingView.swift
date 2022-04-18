//
//  SendingView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 10/06/2021.
//

import SwiftUI

struct SendingView: View {
    @State private var didCopyToClipBoard = false
    @State private var showContactPicker = false
    @State private var allContacts: [Contact] = []
    @State private var selectedContact: Contact = Contact(names: "", phoneNumbers: [])
    @State private var transaction: Transaction = Transaction(amount: "", number: "", type: .client)
        
    private var feeHintView: Text {
        let fee = transaction.estimatedFee
        if fee == -1 {
            return Text("We can not estimate the fee for this amount.")
        } else {
            return Text(String(format: NSLocalizedString("Estimated fee: amount RWF", comment: ""), fee))
        }
    }
    
    var body: some View {
        VStack {
            VStack(spacing: 15) {

                VStack(spacing: 10) {
                    if transaction.type == .client && !transaction.amount.isEmpty {
                        feeHintView
                            .font(.caption).foregroundColor(.blue)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .animation(.default, value: transaction.estimatedFee)
                    }

                    NumberField("Enter Amount", text: $transaction.amount.animation())
                }
                VStack(spacing: 10) {
                    if transaction.type == .client {
                        Text(selectedContact.names).font(.caption).foregroundColor(.blue)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .animation(.default, value: transaction.type)
                    }
                    NumberField(transaction.type == .client ?
                                "Enter Receiver's number" :
                                    "Enter Merchant Code", text: $transaction.number.onChange(handleNumberField).animation())

                    if transaction.type == .merchant {
                        Text("The code should be a 5-6 digits number")
                            .font(.caption).foregroundColor(.blue)
                    }
                }

                VStack(spacing: 18) {
                    if transaction.type == .client {
                        Button(action: {
                            showContactPicker.toggle()
                        }) {
                            HStack {
                                Image(systemName: "person.fill")
                                Text("Pick a contact")
                            }
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                            .shadow(color: .lightShadow, radius: 6, x: -6, y: -6)
                            .shadow(color: .darkShadow, radius: 6, x: 6, y: 6)
                        }
                    }

                    HStack {
                        Button(action: transferMoney) {
                            Text("Dial USSD")
                                .font(.subheadline.bold())
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(Color.blue.opacity(transaction.isValid ? 1 : 0.3))
                                .cornerRadius(8)
                                .foregroundColor(Color.white)
                        }
                        .disabled(transaction.isValid == false)

                        Button(action: copyToClipBoard) {
                            Image(systemName: "doc.on.doc.fill")
                                .frame(width: 48, height: 48)
                                .background(Color.blue.opacity(transaction.isValid ? 1 : 0.3))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                        }
                        .disabled(transaction.isValid == false || didCopyToClipBoard)
                    }
                }
                .padding(.top)

                if didCopyToClipBoard {
                    Text("USSD Code copied!")
                        .font(.system(.callout, design: .rounded))
                        .foregroundColor(Color(.systemBackground))
                        .padding(8)
                        .background(Color.primary.opacity(0.75))
                        .cornerRadius(5)
                        .animation(.easeInOut, value: didCopyToClipBoard)
                }
                Spacer()
            }
            .padding()

        }
        .sheet(isPresented: $showContactPicker) {
            ContactsList(contacts: $allContacts, selection: $selectedContact.onChange(cleanPhoneNumber))
        }
        .background(Color.primaryBackground.ignoresSafeArea().onTapGesture(perform: hideKeyboard))
        .onAppear(perform: requestContacts)
        .navigationTitle("Transfer Money")
        .toolbar {
            Text(transaction.type == .client ? "Pay Merchant" : "Send Money")
                .font(.system(size: 18, design: .rounded))
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
        Task {
            do {
                allContacts = try await PhoneContacts.getMtnContacts()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func cleanPhoneNumber(_ value: Contact?) {
        guard let contact = value else { return }
        let firstNumber  = contact.phoneNumbers.first!
        transaction.number = firstNumber
    }
    
    private func transferMoney() {
        hideKeyboard()
        MainViewModel.performQuickDial(for: .other(transaction.fullCode))
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

    private func copyToClipBoard() {
        UIPasteboard.general.string = transaction.fullCode
        didCopyToClipBoard = true
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            didCopyToClipBoard = false
        }
    }
}

#if DEBUG
struct SendingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SendingView()
//                .preferredColorScheme(.dark)
        }
    }
}
#endif
