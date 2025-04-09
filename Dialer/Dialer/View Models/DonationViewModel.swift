//
//  DonationViewModel.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 09/04/2025.
//  Copyright © 2025 Cédric Bahirwe. All rights reserved.
//

import Foundation

class DonationViewModel: ObservableObject {
    @Published var selectedAmount: Double?
    @Published var customAmount: String = ""
    @Published var isProcessing: Bool = false
    @Published var showThankYou: Bool = false
    @Published var errorMessage: String?

    let donationOptions: [DonationOption] = [
        DonationOption(amount: 5.0, title: "Small", description: "Buy me a coffee"),
        DonationOption(amount: 10.0, title: "Medium", description: "Help with hosting"),
        DonationOption(amount: 25.0, title: "Large", description: "Support development"),
        DonationOption(amount: 50.0, title: "Generous", description: "Become a patron")
    ]

    var finalDonationAmount: Double {
        if let selected = selectedAmount {
            return selected
        } else if let custom = Double(customAmount), custom > 0 {
            return custom
        }
        return 0.0
    }

    var canDonate: Bool {
        finalDonationAmount > 0
    }

    func processDonation() {
        guard canDonate else { return }

        isProcessing = true

        // In a real app, you would:
        // 1. Use StoreKit for IAPs or
        // 2. Connect to a payment processor API

        // This is a simulation of processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Simulate 90% success rate
            if Double.random(in: 0...1) < 0.9 {
                self.showThankYou = true
            } else {
                self.errorMessage = "Transaction failed. Please try again."
            }
            self.isProcessing = false
        }
    }

    func reset() {
        selectedAmount = nil
        customAmount = ""
        showThankYou = false
        errorMessage = nil
    }
}
