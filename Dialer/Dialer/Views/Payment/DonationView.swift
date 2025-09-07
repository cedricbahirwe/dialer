//
//  DonationView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 09/04/2025.
//  Copyright © 2025 Cédric Bahirwe. All rights reserved.
//

import SwiftUI
import StoreKit

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
            VStack(spacing: 20) {
                Image(.dialitApplogo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(.rect(cornerRadius: 15))
                    .padding()

                VStack(spacing: 12) {
                    Text("Privacy over profit")
                        .font(.title3.bold())

//                    Text("Your donation helps us continue to provide and improve our services for free for everyone. Private, open-source, funded by you. No ads, no tracking, no compromise.")
                    Text("Enjoying the app? Leave a tip to show your support. Your contribution helps us keep it free, private, and open-source—without ads, tracking, or compromises.")
                }

                DonationOptionsView(viewModel: viewModel)

//                CustomAmountView(viewModel: viewModel)

                DonateButton(viewModel: viewModel)
            }
            .padding()
        }
        .background(Color.white.opacity(0.01).onTapGesture(perform: hideKeyboard))
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

            if viewModel.products.isEmpty {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(viewModel.products) { product in
                        DonationOptionCard(
                            product: product,
                            isSelected: viewModel.selectedProduct == product,
                            action: {
                                withAnimation {
                                    viewModel.selectedProduct = product
//                                    viewModel.customAmount = ""
                                }
                            }
                        )
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct DonationOptionCard: View {
    let product: Product
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(product.displayName)
                    .font(.headline)

                Text(product.displayPrice)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(gradient: Gradient(colors: [.red, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    )

                Text(product.description)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
            .clipShape(.rect(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(LinearGradient(gradient: Gradient(colors: [.red, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: isSelected ? 2 : 0.03)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

//struct CustomAmountView: View {
//    @ObservedObject var viewModel: DonationViewModel
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text("Or enter custom amount")
//                .font(.headline)
//
//            HStack {
//                Text("$")
//                    .font(.headline)
//                    .foregroundColor(.secondary)
//
//                TextField("Amount", text: $viewModel.customAmount)
//                    .keyboardType(.decimalPad)
//                    .onChange(of: viewModel.customAmount) { _ in
//                        viewModel.selectedProduct = nil
//                    }
//            }
//            .padding()
//            .background(Color.gray.opacity(0.1))
//            .clipShape(.rect(cornerRadius: 8))
//        }
//    }
//}

struct DonateButton: View {
    @ObservedObject var viewModel: DonationViewModel

    var body: some View {
        VStack(spacing: 8) {
            Button(action: {
                Task {
                    await viewModel.processDonation()
                }
            }) {
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
                .font(.system(size: 150))
                .foregroundColor(.pink)

            Text("Thank You!")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Your tip of \(String(format: "$%.2f", viewModel.finalDonationAmount)) has been processed. We appreciate your support!")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()

            Button(action: {
                withAnimation {
                    viewModel.reset()
                }
            }) {
                Text("Make Another Donation")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.mainRed)
                    .foregroundColor(.white)
                    .clipShape(.rect(cornerRadius: 12))
            }

            Button(action: {
                dismiss()
            }) {
                Text("Close")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.primary)
                    .clipShape(.rect(cornerRadius: 12))
            }
        }
        .padding()
    }
}


#Preview {
    DonationView()
//        .preferredColorScheme(.dark)
}
