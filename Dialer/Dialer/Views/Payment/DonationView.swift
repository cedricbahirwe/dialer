//
//  DonationView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 09/04/2025.
//  Copyright © 2025 Cédric Bahirwe. All rights reserved.
//

import SwiftUI

//struct DonationView: View {
//    @StateObject private var viewModel = DonationViewModel()
//    @Environment(\.dismiss) private var dismiss
//
//    @State private var selectedDonation: Int?
//    @State private var customDonation = ""
//    let amounts = [5, 10, 20, 30, 50, 100]
//    var body: some View {
//        VStack(spacing: 0) {
//            Text("Make a Donation to Dialer")
//                .bold()
//                .padding()
//            Divider()
//
//            VStack(spacing: 20) {
//                Image("dialit.applogo")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 80, height: 80)
//                    .clipShape(.rect(cornerRadius: 15))
//
//                Text("Privacy over profit")
//                    .bold()
//
//                Text("Private, open-source, funded by you.No ads, no tracking, no compromise. Free for everyone to use. Donate now to support Dialer App.")
//
//
//                DonationAmountGrid(
//                    selection: $selectedDonation,
//                    amounts: amounts
//                )
//
//                NumberField(
//                    "Enter Custom Amount",
//                    text: Binding(get: {
//                        customDonation
//                    }, set: { value in
//                        if let doubleValue = Int(value) {
//                            selectedDonation = doubleValue
//                        }
//                        customDonation = value
//                    })
//                )
//                .multilineTextAlignment(.center)
//
//                Button {
//
//                } label: {
//                    Text("Continue")
//                        .foregroundStyle(.white)
//                        .bold()
//                        .frame(maxWidth: .infinity)
//                        .padding(6)
//                }
//
//                .buttonStyle(.borderedProminent)
//                .tint(.mainRed)
//                .disabled(selectedDonation == nil)
//            }
//            .padding()
//            .padding(.horizontal)
//        }
//        .frame(maxHeight: .infinity, alignment: .top)
//    }
//}
//
//#Preview {
//    DonationView()
//
//}
//
//import SwiftUI
//
//struct DonationAmountGrid: View {
//    @Binding var selection: Int?
//    let amounts: [Int]
//    let columns = [
//        GridItem(.flexible(), spacing: 16),
//        GridItem(.flexible(), spacing: 16),
//        GridItem(.flexible(), spacing: 16)
//    ]
//
//    var body: some View {
//        LazyVGrid(columns: columns, spacing: 16) {
//            ForEach(amounts, id: \.self) { amount in
//                Button(action: {
//                    withAnimation {
//                        selection = amount
//                    }
//                }) {
//                    Text(amount.formatted(.currency(code: "USD")))
//                        .fontWeight(.medium)
//                        .foregroundStyle(.white)
//                        .frame(maxWidth: .infinity, minHeight: 40)
//                        .background(
//                            Color.blue.opacity(selection == amount ? 1 : 0.6)
//                        )
//                        .cornerRadius(8)
//                }
//            }
//        }
//    }
//}
//
//class DonationViewModel: ObservableObject {
//    
//    @Published var selectedAmount: Double?
//    @Published var customAmount: String = ""
//    @Published var isProcessing: Bool = false
//    @Published var showThankYou: Bool = false
//    @Published var errorMessage: String?
//
//    let donationOptions: [DonationOption] = [
//        DonationOption(amount: 5.0, title: "Small", description: "Buy us a coffee"),
//        DonationOption(amount: 10.0, title: "Medium", description: "Help with hosting"),
//        DonationOption(amount: 25.0, title: "Large", description: "Support development"),
//        DonationOption(amount: 50.0, title: "Generous", description: "Become a patron")
//    ]
//
//    var finalDonationAmount: Double {
//        if let selected = selectedAmount {
//            return selected
//        } else if let custom = Double(customAmount), custom > 0 {
//            return custom
//        }
//        return 0.0
//    }
//
//    var canDonate: Bool {
//        finalDonationAmount > 0
//    }
//
//    func processDonation() {
//        guard canDonate else { return }
//
//        isProcessing = true
//
//        // In a real app, you would:
//        // 1. Use StoreKit for IAPs or
//        // 2. Connect to a payment processor API
//
//        // This is a simulation of processing
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//            // Simulate 90% success rate
//            if Double.random(in: 0...1) < 0.9 {
//                self.showThankYou = true
//            } else {
//                self.errorMessage = "Transaction failed. Please try again."
//            }
//            self.isProcessing = false
//        }
//    }
//
//    func reset() {
//        selectedAmount = nil
//        customAmount = ""
//        showThankYou = false
//        errorMessage = nil
//    }
//
//    struct DonationOption: Identifiable {
//        let id = UUID()
//        let amount: Double
//        let title: String
//        let description: String
//    }
//}


import SwiftUI
import StoreKit

// MARK: - Models

struct DonationOption: Identifiable {
    let id = UUID()
    let amount: Double
    let title: String
    let description: String
}

// MARK: - Views

struct DonationView: View {
    @StateObject private var viewModel = DonationViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            if viewModel.showThankYou {
                DonationThankYouView(viewModel: viewModel)
            } else {
                DonationFormView(viewModel: viewModel)
                    .navigationTitle("Support Us")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close") {
                                dismiss()
                            }
                        }
                    }
                    .alert("Error", isPresented: Binding<Bool>(
                        get: { viewModel.errorMessage != nil },
                        set: { if !$0 { viewModel.errorMessage = nil } }
                    )) {
                        Button("OK", role: .cancel) {}
                    } message: {
                        Text(viewModel.errorMessage ?? "")
                    }
            }
        }
    }
}

struct DonationFormView: View {
    @ObservedObject var viewModel: DonationViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image("dialit.applogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(.rect(cornerRadius: 15))
                    .padding()

                Text("Your donation helps us continue to provide and improve our services.")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                DonationOptionsView(viewModel: viewModel)

                CustomAmountView(viewModel: viewModel)

                DonateButton(viewModel: viewModel)
            }
            .padding()
        }
    }
}

struct DonationOptionsView: View {
    @ObservedObject var viewModel: DonationViewModel
    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 2)

    var body: some View {
        VStack(alignment: .leading) {
            Text("Select an amount")
                .font(.headline)
                .padding(.bottom, 4)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(viewModel.donationOptions) { option in
                    DonationOptionCard(
                        option: option,
                        isSelected: viewModel.selectedAmount == option.amount,
                        action: {
                            viewModel.selectedAmount = option.amount
                            viewModel.customAmount = ""
                        }
                    )
                }
            }
        }
    }
}

struct DonationOptionCard: View {
    let option: DonationOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(option.title)
                    .font(.headline)

                Text("$\(Int(option.amount))")
                    .font(.title3)
                    .fontWeight(.bold)

                Text(option.description)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
            .clipShape(.rect(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.mainRed : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CustomAmountView: View {
    @ObservedObject var viewModel: DonationViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Text("Or enter custom amount")
                .font(.headline)

            HStack {
                Text("$")
                    .font(.headline)
                    .foregroundColor(.secondary)

                TextField("Amount", text: $viewModel.customAmount)
                    .keyboardType(.decimalPad)
                    .onChange(of: viewModel.customAmount) { _ in
                        viewModel.selectedAmount = nil
                    }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

struct DonateButton: View {
    @ObservedObject var viewModel: DonationViewModel

    var body: some View {
        VStack(spacing: 8) {
            Button(action: viewModel.processDonation) {
                HStack {
                    if viewModel.isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(.trailing, 8)
                    }

                    Text(viewModel.isProcessing ? "Processing..." : "Donate \(formattedAmount)")
                        .fontWeight(.semibold)
                }
                .padding(8)
                .frame(maxWidth: .infinity)
                .foregroundStyle(.white)
            }
            .tint(.mainRed)
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.canDonate || viewModel.isProcessing)

            if viewModel.canDonate {
                Text("You'll be charged \(formattedAmount)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    var formattedAmount: String {
        let amount = viewModel.finalDonationAmount
        if amount == 0 { return "" }
        return "$\(String(format: "%.2f", amount))"
    }
}

struct DonationThankYouView: View {
    @ObservedObject var viewModel: DonationViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(.pink)
                .padding()

            Text("Thank You!")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Your donation of \(String(format: "$%.2f", viewModel.finalDonationAmount)) has been processed. We appreciate your support!")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()

            Button(action: {
                viewModel.reset()
            }) {
                Text("Make Another Donation")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.mainRed)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }

            Button(action: {
                dismiss()
            }) {
                Text("Close")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.primary)
                    .cornerRadius(12)
            }
        }
        .padding()
    }
}

// MARK: - Preview

struct DonationView_Previews: PreviewProvider {
    static var previews: some View {
        DonationView()
    }
}
