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
    @State private var transaction: Transaction.Model = .init(amount: "", number: "", type: .merchant)

    @State private var presentedSheet: Sheet?
    private var rowBackground: Color {
        Color(.systemBackground).opacity(colorScheme == .dark ? 0.6 : 1)
    }
    
    private var feeHintView: Text? {
        if transaction.amount.isEmpty {
            return nil
        } else if let fee = transaction.estimatedFee {
            return Text("Estimated fee: \(fee) RWF")
        } else {
            return Text("We can not estimate the fee for this amount.")
        }
    }
    
    private var isMerchant: Bool {
        transaction.type == .merchant
    }

    private var isClient: Bool { !isMerchant }

    private var navigationTitle: String {
        isMerchant ? "Pay Merchant" : "Transfer momo"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 15) {
                VStack(spacing: 10) {
                    if isClient {
                        feeHintView
                            .font(.caption).foregroundStyle(.blue)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    NumberField("Enter Amount", text: $transaction.amount)
                        .onChange(of: transaction.amount, perform: handleAmountChange)
                        .focused($focusedState, equals: .amount)
                        .accessibilityIdentifier("transferAmountField")
                }
                .animation(.default, value: isClient && !transaction.amount.isEmpty)

                VStack(spacing: 10) {
                    if isClient && !selectedContact.names.isEmpty {
                        Text(selectedContact.names).font(.caption).foregroundStyle(.blue)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    HStack {
                        NumberField(
                            isClient
                            ? "Enter Receiver's number"
                            : "Enter Merchant Code",
                            text: $transaction.number.animation())
                        .onChange(of: transaction.number, perform: handleNumberField)
                        .focused($focusedState, equals: .number)
                        .accessibilityIdentifier("transferNumberField")

                        Button(action: {
                            if isClient {
                                hideKeyboard()
                                presentedSheet = .contacts
                                Tracker.shared.logEvent(.contactsOpened)
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
                }
                .animation(.default, value: isClient && !selectedContact.names.isEmpty)

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
            
            if isMerchant {
                MerchantSelectionView(
                    merchantStore: merchantStore,
                    selectedCode: transaction.number,
                    onSelectMerchant: setMerchantSelection
                )
            } else {
                Spacer()
            }
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
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
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: switchPaymentType) {
                    HStack {
                        Image(systemName:  "arrow.left.arrow.right.circle")
                        Text(isClient ? "Pay Merchant" : "Send Money")
                    }
                    .font(.system(size: 18, design: .rounded))
                    .foregroundStyle(.blue)
                    .padding(5)
                }
                .fixedSize()
            }
        }
        .sheet(item: $presentedSheet) { sheet in
            switch sheet {
            case .qrScanner:
                if #available(iOS 17.0, *) {
                    codeScannerView
                        .popoverTip(QRCodeScannerTip())
                } else {
                    codeScannerView
                }
            case .contacts:
                ContactsListView(
                    contacts: allContacts,
                    selection: selectedContact,
                    onSelectContact: {
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
        .task {
            performInitialization()
            await merchantStore.getMerchants()
        }
        .navigationTitle(navigationTitle)
    }
    
    private var alertButtons: [ActionSheet.Button] {
        [.default(Text("This merchant code is incorrect")), .cancel()]
    }

    private var codeScannerView: some View {
        CodeScannerView(codeTypes: [.qr], completion: handleQRScan)
            .ignoresSafeArea()
            .presentationDetents([.medium, .large])
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
        case contacts
        case qrScanner
    }
}

// MARK: - Actions

private extension TransferView {
    func goToNextFocus() {
        focusedState = focusedState?.next()
        if transaction.isValid && focusedState == .number {
            transferMoney()
        }
    }
    
    func performInitialization() {
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
            Tracker.shared.logTransaction(transaction: transaction.cleaned)
        }
    }
    
    /// Create a validation for the `Number` field value
    /// - Parameter value: the validated data
    func handleNumberField(_ value: String) {
        let value = String(value.filter(\.isNumber))
        
        switch transaction.type {
        case .client:
            let matchedContacts = allContacts.filter({ $0.phoneNumbers.contains(value.lowercased())})
            selectedContact = matchedContacts.isEmpty ? .empty : matchedContacts.first!
        case .merchant:
            transaction.number = String(value.prefix(AppConstants.merchantMaxDigits))
            selectedContact = .empty
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
