//
//  TipViewModel.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 09/04/2025.
//  Copyright © 2025 Cédric Bahirwe. All rights reserved.
//

import Foundation
import StoreKit
import SwiftUI

enum TipProcess: Equatable {
    case idle
    case processing
    case completed
    case failed(_ errorMessage: String)
}

@MainActor class TipViewModel: ObservableObject {
    @Published var tipProcess: TipProcess = .idle
    @Published var selectedProduct: Product?
    @Published var products: [Product] = []

    private var transactionListener: Task<Void, Error>?

    private let productIDs: [String] = [
        TipOption("com.dialit.donation.small"),
        TipOption("com.dialit.donation.medium"),
        TipOption("com.dialit.donation.large"),
        TipOption("com.dialit.donation.generous"),
    ].map(\.productID)

    var isProcessing: Bool { tipProcess == .processing }
    var showThankYou: Bool { tipProcess == .completed }
    var errorMessage: String? {
        if case .failed(let message) = tipProcess {
            return message
        }
        return nil
    }

    private var tipAmount: Double {
        guard let selectedProduct else { return 0.0 }
        return NSDecimalNumber(decimal: selectedProduct.price).doubleValue
    }

    var canTip: Bool { tipAmount > 0 }

    var tipDisplayAmount: String {
       selectedProduct?.displayPrice ?? ""
    }

    init() {
        transactionListener = listenForTransactions()

        Task {
            await loadProducts()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    /// Load products from App Store
    func loadProducts() async {
        do {
            products = try await Product.products(for: productIDs).sorted {
                $0.price < $1.price
            }
        } catch {
            self.tipProcess = .failed("Failed to load products: \(error.localizedDescription)")
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

    func processTipping() async {
        guard canTip else { return }

        do {
            guard let product = selectedProduct else {
                throw NSError(domain: "TippingError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Product not available"])
            }

            DispatchQueue.main.async {
                self.tipProcess = .processing
            }

            // Begin a purchase
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                // Check if the transaction is verified
                let transaction = try checkVerified(verification)

                // Handle successful tip
                await handleSuccessfulTransaction()

                // Finish the transaction
                await transaction.finish()
            case .userCancelled:
                await handleUserCancellation()
            case .pending:
                await handlePendingTransaction()
            @unknown default:
                throw NSError(domain: "TippingError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unknown purchase result"])
            }
        } catch {
            await handleTransactionError(error)
        }
    }

    /// Verify the transaction
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw NSError(domain: "TippingError", code: 3, userInfo: [NSLocalizedDescriptionKey: "Transaction verification failed"])
        case .verified(let transaction):
            return transaction
        }
    }

    private func handleSuccessfulTransaction() async {
        // Update firebase records if needed
//         sendTipReceipt(amount: tipAmount)
        SwiftUI.withAnimation {
            tipProcess = .completed
        }
    }

    /// Handle transaction error
    private func handleTransactionError(_ error: Error) async {
        self.tipProcess = .failed("Transaction failed: \(error.localizedDescription)")
    }

    /// Handle user cancellation
    private func handleUserCancellation() async {
        self.tipProcess = .idle
    }

    /// Handle pending transaction
    private func handlePendingTransaction() async {
        self.tipProcess = .failed("Transaction is pending approval.")
    }

    func reset() {
        selectedProduct = nil
        tipProcess = .idle
    }
}
