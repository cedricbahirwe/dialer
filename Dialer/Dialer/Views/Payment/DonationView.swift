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
    @StateObject private var viewModel = TipViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            if viewModel.showThankYou {
                TipThankYouView(tipAmount: viewModel.tipDisplayAmount) {
                    withAnimation {
                        viewModel.reset()
                    }
                }
            } else {
                TipFormView(viewModel: viewModel)
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
                        set: { if !$0 { viewModel.tipProcess = .idle } }
                    )) {
                        Button("OK", role: .cancel) {}
                    } message: {
                        Text(viewModel.errorMessage ?? "")
                    }
            }
        }
    }
}

struct TipFormView: View {
    @ObservedObject var viewModel: TipViewModel

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

                    Text("Enjoying the app? Leave a tip to show your support. Your contribution helps us keep it free, private, and open-source—without ads, tracking, or compromises.")
                }

                TipPickerView(viewModel: viewModel)

                TipButton(viewModel: viewModel)
            }
            .padding()
        }
        .background(Color.white.opacity(0.01).onTapGesture(perform: hideKeyboard))
    }
}

struct TipPickerView: View {
    @ObservedObject var viewModel: TipViewModel
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
                        TipItemView(
                            product: product,
                            isSelected: viewModel.selectedProduct == product,
                            action: {
                                withAnimation {
                                    viewModel.selectedProduct = product
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

struct TipItemView: View {
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

struct TipButton: View {
    @ObservedObject var viewModel: TipViewModel

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

                    Text(viewModel.isProcessing ? "Processing..." : "Tip \(viewModel.tipDisplayAmount)")
                        .fontWeight(.semibold)
                }
                .padding(8)
                .frame(maxWidth: .infinity)
            }
            .tint(.mainRed)
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.canTip || viewModel.isProcessing)

            if viewModel.canTip {
                Text("You'll be charged \(viewModel.tipDisplayAmount)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct TipThankYouView: View {
    var tipAmount: String
    var onTipAgain: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var animateHeart = false

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 150))
                .foregroundStyle(.pink)
                .scaleEffect(animateHeart ? 1.2 : 1)
                .animation(.bouncy.delay(0.25), value: animateHeart)
                .padding(.bottom)

            Text("Thank You!")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Your tip of \(tipAmount) has been processed. We appreciate your support!")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()

            Button(action: onTipAgain) {
                Text("Send Another Tip")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.mainRed)
                    .foregroundStyle(.white)
                    .clipShape(.rect(cornerRadius: 12))
            }

            Button(action: {
                dismiss()
            }) {
                Text("Close")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .foregroundStyle(.primary)
                    .clipShape(.rect(cornerRadius: 12))
            }
        }
        .padding()
        .onAppear {
            animateHeart = true
        }
    }
}


#Preview {
    DonationView()
//        .preferredColorScheme(.dark)
}
