//
//  PurchaseDetailView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 04/04/2021.
//

import SwiftUI

struct PurchaseDetailView: View {
    @ObservedObject var data: MainViewModel
    private enum Field {
        case amount, code
    }
    @State private var edition: Field = .amount
    
    @State private var codepin: String = ""
    
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
            VStack(spacing: 15) {
                
                Text(validAmount ? data.purchaseDetail.amount.description : "Enter Amount")
                    .opacity(validAmount ? 1 : 0.6)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(Color.primary.opacity(0.06))
                    
                    .background(
                        Color.green.opacity(edition == .amount ? 0.04 : 0)
                    )
                    .cornerRadius(8)
                    .overlay(
                        ZStack {
                            if edition == .amount {
                                fieldBorder
                            }
                        }
                    )
                    .onTapGesture {
                        withAnimation {
                            edition = .amount
                        }
                    }
                
                if !data.hasStoredPinCode {
                    VStack(spacing: 2) {
                        Text(data.pinCode != nil ? data.pinCode!.description : "Enter Pin")
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(Color.primary.opacity(0.06))
                            
                            .background(
                                Color.green.opacity(edition == .code ? 0.04 : 0.0)
                            )
                            .cornerRadius(8)
                            .overlay(
                                ZStack {
                                    if edition == .code {
                                        fieldBorder
                                    }
                                }
                            )
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation {
                                    edition = .code
                                }
                            }
                            .overlay(
                                Button(action: {
                                    data.savePinCode(value: Int(codepin)!)
                                    codepin = ""
                                }){
                                    Text("Save")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .frame(width: 60, height: 40)
                                        .background(Color.primary)
                                        .cornerRadius(8)
                                        .foregroundColor(Color(.systemBackground))
                                }
                                .disabled(!validCode)
                                .opacity(validCode ? 1 : 0.4)
                                , alignment: .trailing
                        )
                        
                        Text("Your pin will not be saved unless you personally save it.")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                } else {
                    Text("We've got your back 🎉\n Enter the amount and we'll take care of the rest✌🏾")
                        .foregroundColor(.green)
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 5)
                }
                
                Button {
                    data.confirmPurchase()
                    
                } label: {
                    Text("Confirm")
                        .frame(maxWidth: .infinity)
                        .frame(height: 45)
                        .background(Color.primary)
                        .cornerRadius(8)
                        .foregroundColor(Color(.systemBackground))
                }
                .disabled(!validCode || !validAmount)
            }
            
            PinView(input: storeInput())
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .padding(.bottom, 20)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .top)
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
        .offset(y: 0 + (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0))
        .font(.system(size: 18, weight: .semibold, design: .rounded))
        .offset(x: 0, y: data.showbottomSheet ? 0 : 800)
        .offset(y: max(0, bottomState.height))
        .blur(radius: show ? 20 : 0)
        .animation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.8))
        .gesture(
            DragGesture().onChanged { value in
                bottomState = value.translation
                if showFull {
                    bottomState.height += -300
                }
                if bottomState.height < -300 {
                    bottomState.height = -300
                }
            }
            .onEnded { value in
                if bottomState.height > 50 {
                    data.showbottomSheet = false
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
//        .onChange(of: codepin) { value in
//            if value.count <= 5 {
//                data.pinCode =  Int(value)
//            } else {
//                codepin = String(data.pinCode!)
//            }
//        }
    }
    private func filterPin(_ value: String) {
        codepin = String(value.prefix(5))
        data.pinCode = Int(codepin)
    }
    
    private func storeInput() -> Binding<String>{
        switch edition {
        case .amount:
            return $data.purchaseDetail.amount.stringBind
        case .code:
            return $codepin.onChange(filterPin)
        }
    }
    
}

struct PurchaseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            ZStack(alignment: .bottom) {
                Spacer()
                    .background(Color.red)
                PurchaseDetailView(data: MainViewModel())
            }
        }
    }
}

