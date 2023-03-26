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
    @State private var editedField: EditedField = .amount
    @State private var codepin: String = ""
    @State private var didCopyToClipBoard: Bool = false
    
    private var validCode: Bool {
        if let pin = data.pinCode {
            return String(pin).count == 5
        }
        return false
    }
    
    private var validAmount: Bool {
        data.purchaseDetail.amount > 0
    }
    
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
                
                Text(validAmount ? data.purchaseDetail.amount.description : NSLocalizedString("Enter Amount", comment: ""))
                    .opacity(validAmount ? 1 : 0.6)
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
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 10)
                                    .frame(height: 40)
                                    .background(Color.primary)
                                    .cornerRadius(8)
                                    .foregroundColor(Color(.systemBackground))
                            }
                                .disabled(!validCode)
                                .opacity(validCode ? 1 : 0.4)
                            , alignment: .trailing
                        )
                        
                        Text("Your pin will not be saved unless you manually save it.")
                            .font(.caption)
                            .foregroundColor(.red)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    
                } else {
                    Text("We've got your back 🎉\n Enter the amount and you're good to go✌🏾")
                        .foregroundColor(.green)
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 5)
                }
                
                if UIApplication.hasSupportForUSSD {
                    Button(action: data.confirmPurchase) {
                        Text("Confirm")
                            .frame(maxWidth: .infinity)
                            .frame(height: 45)
                            .background(Color.primary.opacity((!validCode || !validAmount) ? 0.5 : 1))
                            .cornerRadius(8)
                            .foregroundColor(Color(.systemBackground))
                    }
                    .disabled(!validCode || !validAmount)
                } else {
                    VStack(spacing: 6) {
                        Button(action: {
                            data.confirmPurchase()
                            copyToClipBoard()
                        }) {
                            Label("Copy USSD code", systemImage: "doc.on.doc.fill")
                                .frame(maxWidth: .infinity)
                                .frame(height: 45)
                                .background(Color.primary.opacity((!validCode || !validAmount) ? 0.5 : 1))
                                .cornerRadius(8)
                                .foregroundColor(Color(.systemBackground))
                        }
                        .disabled(!validCode || !validAmount)
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
        .padding([.horizontal, .bottom])
        .frame(maxWidth: .infinity, alignment: .top)
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
            Spacer()
            ZStack(alignment: .bottom) {
                Spacer()
                    .background(Color.red)
                PurchaseDetailView(isPresented: .constant(true), data: MainViewModel())
            }
        }
    }
}
#endif
