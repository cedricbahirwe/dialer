//
//  DonationView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 09/04/2025.
//  Copyright © 2025 Cédric Bahirwe. All rights reserved.
//

import SwiftUI

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
                    .trackAppearance(.tipping)
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
