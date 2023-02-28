//
//  SendingView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 10/06/2021.
//

import SwiftUI

struct SendingView: View {
    @EnvironmentObject private var merchantStore: MerchantStore
    @EnvironmentObject private var locationManager: LocationManager
    @Environment(\.colorScheme) private var colorScheme
    @State private var nearbyMerchants: [Merchant] = []
    @State private var didCopyToClipBoard = false
    @State private var showContactPicker = false
    @State private var allContacts: [Contact] = []
    @State private var selectedContact: Contact = Contact(names: "", phoneNumbers: [])
    @State private var transaction: Transaction = Transaction(amount: "", number: "", type: .client)

    private var rowBackground: Color {
        Color.secondary.opacity(colorScheme == .dark ? 0.1 : 0.15)
    }

    private var feeHintView: Text {
        let fee = transaction.estimatedFee
        if fee == -1 {
            return Text("We can not estimate the fee for this amount.")
        } else {
            return Text(String(format: NSLocalizedString("Estimated fee: amount RWF", comment: ""), fee))
        }
    }
    
    var body: some View {
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
                    }                 }
                
                HStack {
                    if UIApplication.hasSupportForUSSD {
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
                    } else {
                        Button(action: copyToClipBoard) {
                            Label("Copy USSD code", systemImage: "doc.on.doc.fill")
                                .foregroundColor(.white)
                                .font(.subheadline.bold())
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(Color.blue.opacity(transaction.isValid ? 1 : 0.3))
                                .cornerRadius(8)
                                .foregroundColor(Color.white)
                        }
                        .disabled(transaction.isValid == false || didCopyToClipBoard)
                    }
                }
            }
            .padding(.top)
            
            if didCopyToClipBoard {
                CopiedUSSDLabel()
            }

            if !nearbyMerchants.isEmpty {
                Section("Other") {
                    ForEach(nearbyMerchants) { merchant in
                        HStack {
                            Text(merchant.name)

                            Spacer()
                            Text(merchant.code)
//                            if editMode?.wrappedValue.isEditing == true {
//                                Text("Edit")
//                                    .font(.caption)
//                                    .foregroundColor(.white)
//                                    .frame(maxHeight: .infinity)
//                                    .frame(width: 60)
//                                    .background(Color.blue)
//                                    .clipShape(Capsule())
//                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
//                        .onTapGesture {
//                            if isEditingMode {
//                                editedUSSDModel = .init(code)
//                            } else {
//                                MainViewModel.performQuickDial(for: .other(code.ussd))
//
//                            }
//                        }
                    }
//                    .onDelete(perform: store.deleteUSSD)
                }
                .listRowBackground(rowBackground)
            }
            Spacer()
        }
        .padding()
         
        .sheet(isPresented: $showContactPicker) {
            ContactsListView(contacts: $allContacts, selection: $selectedContact.onChange(cleanPhoneNumber))
        }
        .background(Color.primaryBackground.ignoresSafeArea().onTapGesture(perform: hideKeyboard))
        .onAppear(perform: initialization)
        .navigationTitle("Transfer Money")
        .toolbar {
            Button(action: switchPaymentType) {
                Text(transaction.type == .client ? "Pay Merchant" : "Send Money")
                    .font(.system(size: 18, design: .rounded))
                    .foregroundColor(.blue)
                    .padding(5)
            }
        }
    }
}

extension SendingView {

    func initialization() {
        getNearbyMerchants()
        requestContacts()
    }

    func switchPaymentType() {
        withAnimation {
            transaction.type.toggle()
        }
    }

    func getNearbyMerchants() {
        if let userLocation = locationManager.userLocation {
            nearbyMerchants = merchantStore.getNearbyMerchants(userLocation)
        }
    }

    func requestContacts() {
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
        withAnimation { didCopyToClipBoard = true }

        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            withAnimation {
                didCopyToClipBoard = false
            }
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
