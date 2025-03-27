//
//  TransferView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 10/06/2021.
//

import SwiftUI
import DialerTO

struct TransferView: View {
    @EnvironmentObject private var merchantStore: UserMerchantStore
    @Environment(\.colorScheme) private var colorScheme

    @FocusState private var focusedState: FocusField?
    @State private var showReportSheet = false
    @State private var allContacts: [Contact] = []
    @State private var selectedContact: Contact = .empty
    @State private var transaction: Transaction.Model = .init(amount: "150500", number: "", type: .client)

    @State private var presentedSheet: Sheet?
    private var rowBackground: Color {
        Color(.systemBackground).opacity(colorScheme == .dark ? 0.6 : 1)
    }

    var smartGradient: LinearGradient {
        LinearGradient(
            colors: [.orange, .red, .purple, .blue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
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

    private var transactionSavings: Int? {
        // Will need more more
        guard isClient else { return nil }
        guard let fees = TransactionOptimizer.calculateFeesSavings(
            for: Int(transaction.doubleAmount)
        ), fees.savings > 0 else {
            return nil
        }

        return fees.savings
    }


    @State private var showSplitInfoSheet: Bool = false
    @State private var otWrapper: OptimizedTransactionsWrapper?
    struct OptimizedTransactionsWrapper: Identifiable {
        var id: UUID
        var transactions: [Transaction.Model]
        init(_ transactions: [Transaction.Model]) {
            self.id = UUID()
            self.transactions = transactions
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 15) {
                VStack(spacing: 10) {
                    if isClient {
                        feeHintView
                            .font(.caption)
                            .foregroundStyle(Color.accentColor)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    VStack(spacing: 2) {
                        HStack {
                            NumberField("Enter Amount", text: $transaction.amount)
                                .onChange(of: transaction.amount, perform: handleAmountChange)
                                .focused($focusedState, equals: .amount)
                                .accessibilityIdentifier("transferAmountField")

                            if transactionSavings != nil {
                                Button(action: {
                                    // Demonstration and performance testing
                                    func demonstrateOptimization(amount: Int) {
                                        let startTime = CFAbsoluteTimeGetCurrent()

                                        let optimizedTransactions = TransactionOptimizer.optimizeTransactions(totalAmount: amount)

                                        let endTime = CFAbsoluteTimeGetCurrent()
                                        let executionTime = (endTime - startTime) * 1000 // Convert to milliseconds

                                        print("Total amount: \(amount)")
                                        print("Optimized transactions: \(optimizedTransactions)")

                                        if let defaultFee = TransactionOptimizer.calculateFee(for: amount),
                                           let totalFee = TransactionOptimizer.calculateTotalFee(for: optimizedTransactions) {
                                            print("Total fee: \(totalFee) vs Default fee: \(defaultFee)")
                                            print("Transactions sum: \(optimizedTransactions.reduce(0, +))")
                                            print("Execution time: \(String(format: "%.4f", executionTime)) ms")

                                            // Print individual transaction fees
                                            for transaction in optimizedTransactions {
                                                if let fee = TransactionOptimizer.calculateFee(for: transaction) {
                                                    print("Transaction \(transaction): Fee = \(fee)")
                                                }
                                            }
                                        } else {
                                            print("Invalid transaction split")
                                        }
                                    }

                                    // Performance test function
                                    func runPerformanceTest() {
                                        let testAmounts = [1_000, 10_000, 100_000, 1_000_000, 5_000_000, 10_000_000]

                                        print("Performance Test:")
                                        for amount in testAmounts {
                                            demonstrateOptimization(amount: amount)
                                            print("---")
                                        }
                                    }

                                    // Uncomment to run performance test
                                    //                                    runPerformanceTest()

                                    // Example usage
                                    demonstrateOptimization(amount: Int(transaction.doubleAmount))

                                    showSplitInfoSheet.toggle()
                                }) {
                                    Image(systemName: "bubbles.and.sparkles.fill")
                                        .imageScale(.large)
                                        .foregroundStyle(
                                            smartGradient
                                        )
                                        .frame(width: 48, height: 48)
                                        .background(.regularMaterial)
                                        .cornerRadius(8)
                                }
                            }
                        }

                        if let transactionSavings {
                            Text("You can save \(transactionSavings) RWF using Dialer Splits")
                                .foregroundStyle(smartGradient)
                                .font(.callout)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else {

                            //                            Text("Can not dialer split \(transaction.doubleAmount.formatted()).")
                            //                                .foregroundStyle(smartGradient)
                            //                                .font(.callout)
                            //                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .animation(.default, value: isClient && !transaction.amount.isEmpty)
                .animation(.default, value: transactionSavings)

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
        .sheet(item: $otWrapper) { wrapper in
            DialerTransactionsViewer(
                fees: TransactionOptimizer.calculateFeesSavings(
                    for: Int(transaction.doubleAmount))!,
                transactions: wrapper.transactions
            )
            .presentationDetents([.height(CGFloat(290 + (20 * wrapper.transactions.count)))])
        }
        .sheet(isPresented: $showSplitInfoSheet) {
            if #available(iOS 16.4, *) {
                DialerSplitInfoView(
                    isPresented: $showSplitInfoSheet,
                    onTurnOn: {
                        let currentTransaction = transaction

                        let otsAmounts = TransactionOptimizer.optimizeTransactions(
                            totalAmount: Int(
                                currentTransaction.doubleAmount
                            )
                        )

                        let ots = otsAmounts.map(
                            { amount in
                                Transaction.Model(
                                    amount: String(amount),
                                    number: currentTransaction.number,
                                    type: currentTransaction.type
                                )
                            })

                        otWrapper = .init(ots)
                    }
                )
                .presentationDetents([.height(370)])
                .presentationBackground(.ultraThickMaterial.shadow(.inner(color: .primary, radius: 10)))
                .presentationCornerRadius(30)
                .presentationContentInteraction(.resizes)
            } else {
                DialerSplitInfoView(
                    isPresented: $showSplitInfoSheet,
                    onTurnOn: {

                    }
                )
                .presentationDetents([.height(370)])
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
            //            focusedState = .amount
        }

        requestContacts()

        let currentTransaction = transaction

        let otsAmounts = TransactionOptimizer.optimizeTransactions(
            totalAmount: Int(
                currentTransaction.doubleAmount
            )
        )

        let ots = otsAmounts.map(
            { amount in
                Transaction.Model(
                    amount: String(amount),
                    number: currentTransaction.number,
                    type: currentTransaction.type
                )
            })

        otWrapper = .init(ots)
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
    .preferredColorScheme(.dark)
}

struct DialerTransactionsViewer: View {
    var fees: (savings: Int, originalFee: Int, optimizedFee: Int)
    var transactions: [Transaction.Model]
    @State private var currentOP = 0
    @State private var showDetails: Bool = true
    var isCompleted: Bool {
        currentOP == transactions.count
    }

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 10) {
            Text("\(fees.savings) RWF Saved")
            //                .foregroundStyle(TransferView().smartGradient)
                .font(.system(.title, design: .rounded, weight: .bold))
                .font(.title.bold())

            HStack(alignment: .lastTextBaseline) {
                Text("\(fees.originalFee) RWF")
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundStyle(.secondary)
                    .strikethrough()

                Text("\(fees.optimizedFee) RWF")
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .foregroundStyle(.mainRed)
            }

            HStack {
                DisclosureGroup(isExpanded: $showDetails) {
                    VStack(alignment: .leading) {
                        ForEach(0..<transactions.count, id: \.self) { i in
                            let transaction = transactions[i]
                            HStack {
                                Text("\(transaction.doubleAmount.formatted(.currency(code: "RWF")))")
                                    .font(.headline.weight(.medium))
                                Spacer()
                                Text("Fee: \(transaction.estimatedFee!.formatted(.currency(code: "RWF")))")
                                    .foregroundStyle(.secondary)
                                Image(systemName: (currentOP > i)  ? "checkmark.circle.fill" : "checkmark.circle")
                                    .foregroundStyle(TransferView().smartGradient)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                } label: {
                    Text("\(transactions.count) total transactions")
                        .font(.title2)

                        .foregroundStyle(TransferView().smartGradient)
                }
            }

            Button {
                if isCompleted {
                    dismiss()
                } else {
                    currentOP += 1
                }
            } label: {
                HStack {
                    Text(isCompleted ? "Complete" : "Confirm \(currentOP+1) out of \(transactions.count)")

                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .imageScale(.large)
                    }
                }
                .font(.subheadline.bold())
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.accentColor, in: .rect(cornerRadius: 12))
                .foregroundStyle(Color.white)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .top) {
            Text("Dialer Splits")
                .bold()
                .foregroundStyle(TransferView().smartGradient)
                .padding()
        }
    }
}

struct DialerSplitInfoView: View {
    @Binding var isPresented: Bool
    var onTurnOn: () -> Void
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "bubbles.and.sparkles.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.orange, .red, .purple, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .padding(.top, 10)

            Text("Dialer Splits")
                .font(.system(.title, design: .rounded, weight: .bold))
                .bold()

            Text(Bool.random()
                 ? "Save on transaction fees with smart split suggestions when sending money."
                 : "Get smart suggestions to reduce transaction fees when sending money.")
            .font(.headline)
            .fontWeight(.regular)
            .multilineTextAlignment(.center)

            Text("You can change this in your settings.")
                .font(.callout)
                .foregroundStyle(.secondary)

            VStack(spacing: 10) {
                Button {
                    isPresented.toggle()
                    onTurnOn()
                } label: {
                    Text("Turn on Split Suggestions")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            LinearGradient(
                                colors: [.orange, .red, .purple, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            in: .rect(cornerRadius: 12)
                        )
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)

                Button {
                } label: {
                    Text("Remind Me Later")
                        .frame(maxWidth: .infinity)
                        .frame(height: 45)
                }
            }
            .padding(.top, 12)
        }
        .padding(.vertical)
        .padding(.horizontal, 20)
    }
}
