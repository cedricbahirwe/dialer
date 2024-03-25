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
    @State private var didCopyToClipBoard: Bool = false
    @State private var show = false
    @State private var bottomState = CGSize.zero
    @State private var showFull = false
    @Namespace private var animation
    
    private let defaultSheetHeight: CGFloat = 300
    private var fieldBorder: some View {
        RoundedRectangle(cornerRadius: 8)
            .stroke(LinearGradient(gradient: Gradient(colors: [Color.green, Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing),  lineWidth:1)
            .matchedGeometryEffect(id: "border", in: animation)
    }
        
    var body: some View {
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
                
                if UIApplication.hasSupportForUSSD {
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
                } else {
                    VStack(spacing: 6) {
                        Button(action: {
                            Task {
                                await data.confirmPurchase()
                            }
                            copyToClipBoard()
                        }) {
                            Label("Copy USSD code", systemImage: "doc.on.doc.fill")
                                .frame(maxWidth: .infinity)
                                .frame(height: 45)
                                .background(Color.primary.opacity((!data.hasValidAmount) ? 0.5 : 1))
                                .cornerRadius(8)
                                .foregroundColor(Color(.systemBackground))
                        }
                        .disabled(!data.hasValidAmount)
                        if didCopyToClipBoard {
                            CopiedUSSDLabel()
                        }
                    }
                }
            }
            
            PinView(input: inputBinding())
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .padding(.vertical)
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
        .offset(x: 0, y: isPresented ? 0 : 800)
        .offset(y: max(0, bottomState.height))
        .blur(radius: show ? 20 : 0)
        .gesture(sheetDragGesture)
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
                    if showFull {
                        bottomState.height += -defaultSheetHeight
                    }
                    if bottomState.height < -defaultSheetHeight {
                        bottomState.height = -defaultSheetHeight
                    }
                }
            }
            .onEnded { value in
                guard !isIOS16 else { return }
                if bottomState.height > 50 {
                    isPresented = false
                }
                if (bottomState.height < -100 && !showFull) || (bottomState.height < -250 && showFull) {
                    bottomState.height = -defaultSheetHeight
                    showFull = true
                } else {
                    bottomState = .zero
                    showFull = false
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
    
    func copyToClipBoard() {
        let fullCode = data.getPurchaseDetailUSSDCode()
        UIPasteboard.general.string = fullCode
        withAnimation {
            didCopyToClipBoard = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            withAnimation {
                didCopyToClipBoard = false
            }
        }
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
