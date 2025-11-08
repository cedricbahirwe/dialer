//
//  AirtimePurchaseSheet.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 04/04/2021.
//

import SwiftUI

struct AirtimePurchaseSheet: View {
    @Binding var isPresented: Bool
    @Binding var transaction: AirtimeTransaction
    var onConfirm: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Capsule()
                .fill(Color.gray)
                .frame(width: 50, height: 5)
                .padding(.vertical, 12)

            VStack(spacing: 10) {
                Text(transaction.isValid ? transaction.amount.description : "Enter Amount")
                    .opacity(transaction.isValid ? 1 : 0.6)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(Color.primary.opacity(0.06))
                    .background(Color.green.opacity(0.04))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.green, Color.accentColor]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing),
                                lineWidth: 1)
                    )

                Button(action: onConfirm) {
                    Text("Continue")
                        .frame(maxWidth: .infinity)
                        .frame(height: 45)
                        .background(Color.accentColor.opacity(transaction.isValid ? 1.0 : 0.1))
                        .cornerRadius(8)
                        .foregroundStyle(transaction.isValid ? .white : .gray)
                }
                .disabled(!transaction.isValid)
            }

            PinView(input: inputBinding())
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .padding(.vertical, 10)
        }
        .font(.system(size: 18, weight: .semibold, design: .rounded))
        .padding([.horizontal, .bottom])
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(
            Color.primaryBackground
                .ignoresSafeArea()
                .shadow(radius: 5)
        )
        .font(.system(size: 18, weight: .semibold, design: .rounded))
        .onChange(of: isPresented) { newValue in
            if newValue {
                Tracker.shared.startSession(for: .buyAirtime)
            } else {
                transaction = .init()
                Tracker.shared.stopSession(for: .buyAirtime)
            }
        }
    }
}

// MARK: - Private Helpers
private extension AirtimePurchaseSheet {
    func inputBinding() -> Binding<String> {
        Binding(
            get: {
                transaction.amount == 0 ? "" :
                String(transaction.amount)
            }, set: {
                transaction.amount = Int($0) ?? 0
            }
        )
    }
}

#Preview {
    Text("Purchase Sheet")
        .sheet(isPresented: .constant(true)) {
            AirtimePurchaseSheet(
                isPresented: .constant(true),
                transaction: .constant(.init(amount: 100)),
                onConfirm: {})
            .presentationDetents([.height(500)])
        }
}
