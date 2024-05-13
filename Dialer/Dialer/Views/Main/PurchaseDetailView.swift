//
//  PurchaseDetailView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 04/04/2021.
//

import SwiftUI

struct PurchaseDetailView: View {
    @Binding var isPresented: Bool
    @ObservedObject var data: MainViewModel
    
    private var fieldBorder: some View {
        RoundedRectangle(cornerRadius: 8)
            .stroke(LinearGradient(gradient: Gradient(colors: [Color.green, Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing),  lineWidth:1)
    }
    
    private var contentView: some View {
        VStack(spacing: 8) {
            Capsule()
                .fill(Color.gray)
                .frame(width: 50, height: 5)
                .padding(.vertical, 12)
            
            VStack(spacing: 10) {
                
                Text(data.hasValidAmount ? data.purchaseDetail.amount.description : "Enter Amount")
                    .opacity(data.hasValidAmount ? 1 : 0.6)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(Color.primary.opacity(0.06))
                    .background(Color.green.opacity(0.04))
                    .cornerRadius(8)
                    .overlay(fieldBorder )
                
                Button(action: {
                    Task {
                        await data.confirmPurchase()
                    }
                }) {
                    Text("Confirm")
                        .frame(maxWidth: .infinity)
                        .frame(height: 45)
                        .background(Color.blue.opacity((!data.hasValidAmount) ? 0.5 : 1))
                        .cornerRadius(8)
                        .foregroundStyle(.white)
                }
                .disabled(!data.hasValidAmount)
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
                .cornerRadius(15)
                .ignoresSafeArea()
                .shadow(radius: 5)
        )
        .font(.system(size: 18, weight: .semibold, design: .rounded))
    }
    
    var body: some View {
        contentView
            .onChange(of: isPresented) { newValue in
                if newValue {
                    Tracker.shared.startSession(for: .buyAirtime)
                } else {
                    Tracker.shared.stopSession(for: .buyAirtime)
                }
            }
    }
}

// MARK: - Private Methods
private extension PurchaseDetailView {
    
    func inputBinding() -> Binding<String> {
        Binding(
            get: {
                data.purchaseDetail.amount == 0 ? "" :
                String(data.purchaseDetail.amount)
            }, set: {
                data.purchaseDetail.amount = Int($0) ?? 0
            }
        )
    }
}

#Preview {
    VStack {
        Text("Purchase Sheet")
            .sheet(isPresented: .constant(true)) {
                PurchaseDetailView(isPresented: .constant(true),
                                   data: MainViewModel())
                .background(.purple)
                .presentationDetents([.height(500)])
            }
    }
}
