//
//  PurchaseDetailView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 04/04/2021.
//

import SwiftUI

struct PurchaseDetailView: View {
    @Binding var isPresented: Bool
    var isIOS16 = false
    @ObservedObject var data: MainViewModel
    @State private var editedField: EditedField = .amount
    @State private var codepin: String = ""
    @State private var didCopyToClipBoard: Bool = false
    
    @State var show = false
    @State var bottomState = CGSize.zero
    @State var showFull = false
    
    @Namespace private var animation
    
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
                .padding(.vertical, 8)
            
            VStack(spacing: 10) {
                
                Text(data.hasValidAmount ? data.purchaseDetail.amount.description : NSLocalizedString("Enter Amount", comment: ""))
                    .opacity(data.hasValidAmount ? 1 : 0.6)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(Color.primary.opacity(0.06))
                    .background(
                        Color.green.opacity(editedField == .amount ? 0.04 : 0)
                    )
                    .cornerRadius(8)
                    .overlay(
                        ZStack {
                            if editedField == .amount {
                                fieldBorder
                            }
                        }
                    )
                    .onTapGesture {
                        withAnimation {
                            editedField = .amount
                        }
                    }

                if !data.hasStoredCodePin() {
                    VStack(spacing: 2) {
                        Text(
                            NSLocalizedString(codepin.isEmpty ? "Enter Pin" : codepin.description,
                                              comment: "")
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(Color.primary.opacity(0.06))

                        .background(
                            Color.green.opacity(editedField == .code ? 0.04 : 0.0)
                        )
                        .cornerRadius(8)
                        .overlay(
                            ZStack {
                                if editedField == .code {
                                    fieldBorder
                                }
                            }
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation {
                                editedField = .code
                            }
                        }
                        .overlay(
                            Button(action: {
                                guard let codepin = try? CodePin(codepin) else { return }
                                data.saveCodePin(codepin)
                                self.codepin = ""
                            }){
                                Text("Save")
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 20)
                                    .frame(height: 40)
                                    .background(Color.primary)
                                    .cornerRadius(8)
                                    .foregroundStyle(.background)
                            }
                                .disabled(!data.isPinCodeValid)
                                .opacity(data.isPinCodeValid ? 1 : 0.4)
                            , alignment: .trailing
                        )

                        Text("Your pin will not be saved unless you manually save it.")
                            .font(.caption)
                            .foregroundColor(.red)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }

                } else {
                    VStack {
                        Text("We've got your back 🎉")
                        Text("Enter the amount and you're good to go✌🏾")
                    }
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.green)
                    .padding(.horizontal, 5)
                }

                if UIApplication.hasSupportForUSSD {
                    Button(action: {
                        data.confirmPurchase()
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
                            data.confirmPurchase()
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
                .padding(.bottom)
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
        .gesture(
            DragGesture()
                .onChanged { value in
                    guard !isIOS16 else { return }
                    withAnimation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.8)) {
                        bottomState = value.translation
                        if showFull {
                            bottomState.height += -300
                        }
                        if bottomState.height < -300 {
                            bottomState.height = -300
                        }
                    }
                }
                .onEnded { value in
                    guard !isIOS16 else { return }
                    if bottomState.height > 50 {
                        isPresented = false
                    }
                    if (bottomState.height < -100 && !showFull) || (bottomState.height < -250 && showFull) {
                        bottomState.height = -300
                        showFull = true
                    } else {
                        bottomState = .zero
                        showFull = false
                    }
                }
        )
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
    func filterPin(_ value: String) {
        codepin = String(value.prefix(5))
        data.pinCode = try? CodePin(codepin)
    }
    
    func inputBinding() -> Binding<String> {
        switch editedField {
        case .amount:
            return Binding {
                data.purchaseDetail.amount == 0 ? "" :
                String(data.purchaseDetail.amount)
            } set: {
                data.purchaseDetail.amount = Int($0) ?? 0
            }
        case .code:
            return $codepin.onChange(filterPin)
        }
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
    
    enum EditedField {
        case amount, code
    }
}

#if DEBUG
struct PurchaseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            if #available(iOS 16.0, *) {
                Text("Purchase Sheet")
                
                .sheet(isPresented: .constant(true)) {
                    PurchaseDetailView(isPresented: .constant(true), isIOS16: true, data: MainViewModel())
                        .background(.purple)
                        .presentationDetents([.height(490)])
                }
            } else {
                Spacer()

                ZStack(alignment: .bottom) {
                    Spacer()
                        .background(Color.red)
                    PurchaseDetailView(isPresented: .constant(true), data: MainViewModel())
                }
            }
        }
        
    }
}
#endif
