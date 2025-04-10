//
//  DonationViewModel.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 09/04/2025.
//  Copyright © 2025 Cédric Bahirwe. All rights reserved.
//

import Foundation
import StoreKit
import SwiftUI

struct DonationOption: Identifiable {
    var id: String { productId }
    let productId: String
    let amount: Double
    let title: String
    let description: String
}

@MainActor
class DonationViewModel: ObservableObject {
    @Published var selectedProduct: Product?
    @Published var customAmount: String = ""
    @Published var isProcessing: Bool = false
    @Published var showThankYou: Bool = false
    @Published var errorMessage: String?
    @Published var products: [Product] = []
    private var transactionListener: Task<Void, Error>?

    let donationOptions: [DonationOption] = [
        DonationOption(productId: "com.dialit.donation.small", amount: 5.0, title: "Small", description: "Buy me a coffee"),
        DonationOption(productId: "com.dialit.donation.medium", amount: 10.0, title: "Medium", description: "Help with hosting"),
        DonationOption(productId: "com.dialit.donation.large", amount: 25.0, title: "Large", description: "Support development"),
        DonationOption(productId: "com.dialit.donation.generous", amount: 50.0, title: "Generous", description: "Become a patron")
    ]

    // Custom donation product IDs (create multiple tiers in App Store Connect)
    let customDonationProducts: [String] = [
        "com.dialit.donation.custom.tier1",  // e.g., $1-15
        "com.dialit.donation.custom.tier2",  // e.g., $16-30
        "com.dialit.donation.custom.tier3",  // e.g., $31-50
        "com.dialit.donation.custom.tier4"   // e.g., $51+
    ]

    var finalDonationAmount: Double {
        if let selected = selectedProduct?.price {
            return NSDecimalNumber(decimal: selected).doubleValue
        } else if let custom = Double(customAmount), custom > 0 {
            return custom
        }
        return 0.0
    }

    var canDonate: Bool {
        finalDonationAmount > 0
    }

    init() {
        // Set up transaction listener
        transactionListener = listenForTransactions()
        // Load products when initialized
        Task {
            await loadProducts()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    /// Get appropriate product for the selected amount
    func productForSelectedAmount() -> Product? {
        let amount = finalDonationAmount

        // For predefined options
        if let productID = donationOptions.first(where: { $0.amount == amount })?.productId {
            return products.first { $0.id == productID }
        }

        // For custom amounts, select appropriate tier
        let tier: String
        if amount <= 15 {
            tier = customDonationProducts[0]
        } else if amount <= 30 {
            tier = customDonationProducts[1]
        } else if amount <= 50 {
            tier = customDonationProducts[2]
        } else {
            tier = customDonationProducts[3]
        }

        return products.first { $0.id == tier }
    }

    /// Load products from App Store
    func loadProducts() async {
        let productIDs = donationOptions.map(\.productId)
        do {
            products = try await Product.products(for: productIDs).sorted {
                $0.price < $1.price
            }
        } catch {
            self.errorMessage = "Failed to load products: \(error.localizedDescription)"
        }
    }

    /// Listen for transactions
    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            // Iterate through any transactions that don't come from a direct call to purchase
            for await result in StoreKit.Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)

                    // Deliver the content
                    await self.handleSuccessfulTransaction()

                    // Finish the transaction
                    await transaction.finish()
                } catch {
                    // Handle transaction error
                    await self.handleTransactionError(error)
                }
            }
        }
    }

    func processDonation() async {
        guard canDonate else { return }

        DispatchQueue.main.async {
            self.isProcessing = true
        }

        do {
            guard let product = productForSelectedAmount() else {
                throw NSError(domain: "DonationError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Product not available"])
            }

            // Begin a purchase
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                // Check if the transaction is verified
                let transaction = try checkVerified(verification)

                // Handle successful donation
                await handleSuccessfulTransaction()

                // Finish the transaction
                await transaction.finish()
            case .userCancelled:
                await handleUserCancellation()
            case .pending:
                await handlePendingTransaction()
            @unknown default:
                throw NSError(domain: "DonationError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unknown purchase result"])
            }
        } catch {
            await handleTransactionError(error)
        }
    }

    /// Verify the transaction
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw NSError(domain: "DonationError", code: 3, userInfo: [NSLocalizedDescriptionKey: "Transaction verification failed"])
        case .verified(let transaction):
            return transaction
        }
    }

    private func handleSuccessfulTransaction() async {
        // Update firebase records if needed
        // sendDonationReceipt(amount: finalDonationAmount)
        SwiftUI.withAnimation {
            showThankYou = true
            isProcessing = false
        }
    }

    // Handle transaction error
    private func handleTransactionError(_ error: Error) async {
        errorMessage = "Transaction failed: \(error.localizedDescription)"
        isProcessing = false
    }

    // Handle user cancellation
    private func handleUserCancellation() async {
        isProcessing = false
    }

    // Handle pending transaction
    private func handlePendingTransaction() async {
        errorMessage = "Transaction is pending approval."
        isProcessing = false
    }

    func initiateProcessDonation() {
        Task {
            await processDonation()
        }
    }

    func reset() {
        selectedProduct = nil
        customAmount = ""
        showThankYou = false
        errorMessage = nil
    }
}
