//
//  TransferView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 10/06/2021.
//

import SwiftUI

struct TransferView: View {
    @EnvironmentObject private var merchantStore: UserMerchantStore
    @Environment(\.colorScheme) private var colorScheme
    
    @FocusState private var focusedState: FocusField?
    @State private var showReportSheet = false
    @State private var allContacts: [Contact] = []
    @State private var selectedContact: Contact = .empty
    @State private var transaction: Transaction = Transaction(amount: "", number: "", type: .merchant)
    
    @State private var presentedSheet: Sheet?
    
    private var rowBackground: Color {
        Color(.systemBackground).opacity(colorScheme == .dark ? 0.6 : 1)
    }
    
    private var feeHintView: Text {
        let fee = transaction.estimatedFee
        if fee == -1 {
            return Text("We can not estimate the fee for this amount.")
        } else {
            return Text("Estimated fee: \(fee) RWF")
        }
    }
    
    private var isMerchant: Bool {
        transaction.type == .merchant
    }
    
    private var navigationTitle: String {
        transaction.type == .merchant ? "Pay Merchant" : "Transfer momo"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            VStack(spacing: 15) {
                
                VStack(spacing: 10) {
                    if transaction.type == .client && !transaction.amount.isEmpty {
                        feeHintView
                            .font(.caption).foregroundStyle(.blue)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .animation(.default, value: transaction.estimatedFee)
                    }
                    
                    NumberField("Enter Amount", text: $transaction.amount)
                        .onChange(of: transaction.amount, perform: handleAmountChange)
                        .focused($focusedState, equals: .amount)
                        .accessibilityIdentifier("transferAmountField")
                }
                
                VStack(spacing: 10) {
                    if transaction.type == .client {
                        Text(selectedContact.names).font(.caption).foregroundStyle(.blue)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .animation(.default, value: transaction.type)
                    }
                    HStack {
                        NumberField(transaction.type == .client ?
                                    "Enter Receiver's number" :
                                        "Enter Merchant Code", text: $transaction.number.onChange(handleNumberField).animation())
                        .focused($focusedState, equals: .number)
                        .accessibilityIdentifier("transferNumberField")
                        
                        
                        Button(action: {
                            if transaction.type == .client {
                                hideKeyboard()
                                presentedSheet = .contacts
                                Tracker.shared.logEvent(.conctactsOpened)
                            } else {
                                openScanner()
                            }
                        }) {
                            Image(systemName: isMerchant ?  "qrcode.viewfinder" : "person.fill")
                                .imageScale(.large)
                                .frame(width: 48, height: 48)
                                .background(Color.accentColor)
                                .cornerRadius(8)
                                .foregroundStyle(.white)
                        }
                    }
                    
                    if transaction.type == .merchant {
                        Text("Merchant code should be a 5-6 digits number")
                            .font(.caption).foregroundStyle(.blue)
                    }
                }
                
                VStack(spacing: 18) {
                    Button(action: {
                        hideKeyboard()
                        transferMoney()
                    }) {
                        Text("Dial USSD")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.blue.opacity(transaction.isValid ? 1 : 0.3))
                            .cornerRadius(8)
                            .foregroundStyle(Color.white)
                    }
                    .disabled(transaction.isValid == false)
                }
                .padding(.top)
            }
            .padding()
            
            if transaction.type == .merchant {
                List {
                    Section {
                        if merchantStore.merchants.isEmpty {
                            Text("No Merchants Saved Yet.")
                                .opacity(0.5)
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: 50)
                            
                        } else {
                            ForEach(merchantStore.merchants) { merchant in
                                HStack {
                                    HStack(spacing: 4) {
                                        if merchant.code == transaction.number {
                                            Image(systemName: "checkmark")
                                                .foregroundStyle(.blue)
                                                .font(.body.weight(.semibold))
                                        }
                                        
                                        Text(merchant.name)
                                            .lineLimit(1)
                                    }
                                    Spacer()
                                    Text("#\(merchant.code)")
                                        .font(.callout.weight(.medium))
                                        .foregroundStyle(.blue)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    setMerchantSelection(merchant)
                                }
                                .listRowInsets(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                            }
                            .onDelete(perform: deleteMerchant)
                        }
                    } header: {
                        HStack {
                            Text("Saved Merchants")
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.semibold)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                            
                            Spacer(minLength: 1)
                            
                            if merchantStore.isFetching {
                                ProgressView()
                                    .tint(.blue)
                            } else {
                                Button {
                                    presentedSheet = .merchants
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .imageScale(.large)
                                }
                            }
                            
                        }
                    } footer: {
                        if !merchantStore.merchants.isEmpty {
                            Text("Please make sure the merchant code is correct before dialing.\nNeed Help? Go to ***Settings -> Contact Us***")
                        }
                    }
                    .listRowBackground(rowBackground)
                }
                .scrollContentBackground(.hidden)
            } else {
                Spacer()
            }
        }
        .sheet(item: $presentedSheet) { sheet in
            switch sheet {
            case .qrScanner:
                CodeScannerView(codeTypes: [.qr], completion: handleQRScan)
                    .ignoresSafeArea()
                    .presentationDetents([.medium, .large])
            case .merchants:
                CreateMerchantView(merchantStore: merchantStore)
            case .contacts:
                ContactsListView(
                    contacts: allContacts,
                    selection: selectedContact,
                    completion: {
                        selectedContact = $0
                        cleanPhoneNumber(selectedContact)
                        presentedSheet = nil
                    })
            }
        }
        .actionSheet(isPresented: $showReportSheet) {
            ActionSheet(
                title: Text("Report a problem."),
                buttons: alertButtons)
        }
        .background(Color.primaryBackground.ignoresSafeArea().onTapGesture(perform: hideKeyboard))
        .trackAppearance(.transfer)
        .onAppear(perform: initialization)
        .navigationTitle(navigationTitle)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                HStack {
                    Spacer()
                    Button(action: goToNextFocus) {
                        Text(focusedState == .number ? " Finish" : "Next")
                            .font(.system(size: 18, design: .rounded))
                            .foregroundStyle(.blue)
                            .padding(5)
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: switchPaymentType) {
                    Text(transaction.type == .client ? "Pay Merchant" : "Send Money")
                        .font(.system(size: 18, design: .rounded))
                        .foregroundStyle(.blue)
                        .padding(5)
                }
            }
        }
    }
    
    private var alertButtons: [ActionSheet.Button] {
        [.default(Text("This merchant code is incorrect")), .cancel()]
    }
    
    private func deleteMerchant(at offSets: IndexSet) {
        merchantStore.deleteMerchants(at: offSets)
    }
}

private extension TransferView {
    enum FocusField {
        case amount, number
        func next() -> Self? {
            self == .amount ? .number : nil
        }
    }
    enum Sheet: Int, Identifiable {
        var id: Int { rawValue }
        case merchants
        case contacts
        case qrScanner
    }
}

private extension TransferView {
    
    func goToNextFocus() {
        focusedState = focusedState?.next()
        if transaction.isValid && focusedState == .number {
            transferMoney()
        }
    }
    
    func initialization() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            focusedState = .amount
        }
        
        requestContacts()
    }
    
    func switchPaymentType() {
        withAnimation {
            transaction.type.toggle()
        }
    }
    
    func requestContacts() {
        Task {
            do {
                allContacts = try await PhoneContacts.getMtnContacts()
            } catch {
                Tracker.shared.logError(error: error)
                Log.debug(error.localizedDescription)
            }
        }
    }
    
    func cleanPhoneNumber(_ contact: Contact) {
        guard let selectedPhoneNumber = contact.phoneNumbers.first else { return }
        transaction.number = selectedPhoneNumber
    }
    
    
    func transferMoney() {
        guard transaction.isValid else { return }
        Task {
            await MainViewModel.performQuickDial(for: .other(transaction.fullCode))
            Tracker.shared.logTransaction(transaction: transaction)
        }
    }
    
    /// Create a validation for the `Number` field value
    /// - Parameter value: the validated data
    func handleNumberField(_ value: String) {
        let value = String(value.filter(\.isNumber))
        
        if transaction.type == .merchant {
            transaction.number = String(value.prefix(6))
            selectedContact = .empty
        } else {
            let matchedContacts = allContacts.filter({ $0.phoneNumbers.contains(value.lowercased())})
            selectedContact = matchedContacts.isEmpty ? .empty : matchedContacts.first!
        }
    }
    
    func handleAmountChange(_ newAmount: String) {
        let cleanAmount = String(newAmount.filter(\.isNumber))
        if cleanAmount.first == "0" {
            transaction.amount = String(cleanAmount.dropFirst())
        } else {
            transaction.amount = cleanAmount
        }
    }
    
    func openScanner() {
        hideKeyboard()
        presentedSheet = .qrScanner
    }
    
    func handleQRScan(result: Result<ScanResult, ScanError>) {
        presentedSheet = nil
        
        switch result {
        case .success(let scan):
            if let code = Merchant.extractMerchantCode(from: scan.string) {
                Tracker.shared.logMerchantScan(code)
                transaction.number = code
                transferMoney()
            } else {
                focusedState = .number
            }
        case .failure(let error):
            Tracker.shared.logError(error: error)
        }
    }
    
    func setMerchantSelection(_ merchant: Merchant) {
        withAnimation {
            transaction.number = merchant.code
        }
        Tracker.shared.logMerchantSelection(merchant)
    }
}

#Preview {
    NavigationStack {
        TransferView()
            .environmentObject(UserMerchantStore())
    }
}
