//
//  PurchaseDetailView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 04/04/2021.
//

import SwiftUI

struct PurchaseDetailView: View {
    @Binding var isPresented: Bool
    let isIOS16: Bool
    @ObservedObject var data: MainViewModel
    @State private var bottomState = CGSize.zero
    
    private let defaultSheetHeight: CGFloat = 300
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
                        .foregroundColor(.white)
                }
                .disabled(!data.hasValidAmount)
            }
            
            PinView(input: inputBinding())
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .padding(.vertical, 10)
        }
        .font(.system(size: 18, weight: .semibold, design: .rounded))
        .padding([.horizontal, .bottom])
        .frame(maxWidth: .infinity, alignment: .top)
        .frame(maxHeight: isIOS16 ? .infinity : nil, alignment: .top)
        .background(
            Color.primaryBackground
                .cornerRadius(15)
                .ignoresSafeArea()
                .shadow(radius: 5)
        )
        .font(.system(size: 18, weight: .semibold, design: .rounded))
        .offset(y: max(0, bottomState.height))
        .offset(x: 0, y: isPresented ? 0 : 800)
    }
    
    var body: some View {
        Group {
            if isIOS16 {
                contentView
            } else {
                contentView
                    .gesture(sheetDragGesture)
            }
        }
        .onChange(of: isPresented) { newValue in
            if newValue {
                Tracker.shared.startSession(for: .buyAirtime)
            } else {
                Tracker.shared.stopSession(for: .buyAirtime)
            }
        }
    }
    
    private var sheetDragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                guard !isIOS16 else { return }
                withAnimation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.8)) {
                    bottomState = value.translation
                }
            }
            .onEnded { value in
                guard !isIOS16 else { return }
                if bottomState.height > 100 {
                    withAnimation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.8)) {
                        bottomState.height = defaultSheetHeight + 200
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        resetView()
                    }
                } else {
                    withAnimation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.8)) {
                        bottomState = .zero
                    }
                }
            }
    }
    
    private func resetView() {
        isPresented = false
        bottomState = .zero
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

struct PurchaseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            if #available(iOS 16.0, *) {
                Text("Purchase Sheet")
                    .sheet(isPresented: .constant(true)) {
                        PurchaseDetailView(isPresented: .constant(true),
                                           isIOS16: true, data: MainViewModel())
                        .background(.purple)
                        .presentationDetents([.height(500)])
                    }
            } else {
                Spacer()
                
                ZStack(alignment: .bottom) {
                    Spacer()
                    
                    PurchaseDetailView(
                        isPresented: .constant(true),
                        isIOS16: false,
                        data: MainViewModel()
                    )
                }
            }
        }
    }
}
