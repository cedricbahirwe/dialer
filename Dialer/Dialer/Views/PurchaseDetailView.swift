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
        case amount, code, none
    }
    @State private var edition: Field = .amount
    
    @State private var fieldValue: String = ""
    @State private var codepin: String = ""
    
    private var validCode: Bool {
        if let pin = data.pinCode {
            return String(pin).count == 5
        }
        return false
    }
    
    private var hasStorePin: Bool {
        return UserDefaults.standard.integer(forKey: UserDefaults.Keys.PinCode) != 0
    }
    
    private var validAmount: Bool {
        data.purchaseDetail.amount > 0
    }
    
    @State var show = false
    @State var viewState = CGSize.zero
    @State var bottomState = CGSize.zero
    @State var showFull = false
    
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
                    .onTapGesture {
                        withAnimation {
                            edition = .amount
                        }
                    }
                
                if !hasStorePin {
                    Text(data.pinCode != nil ? data.pinCode!.description : "Enter Code")
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(Color.primary.opacity(0.06))
                        .background(
                            Color.green.opacity(edition == .code ? 0.04 : 0.0)
                        )
                        .cornerRadius(8)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation {
                                edition = .code
                            }
                        }
                        .overlay(
                            Button(action: {
                                data.savePinCode(value: Int(codepin)!)
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
                    
                    
                } else {
                    Text("We've got your back 🎉\n Enter the amount and we'll take care of the rest✌🏾")
                        .foregroundColor(.green)
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 5)
                }
                
                Button {
                    edition = .none
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
        .offset(x: 0, y: data.showbottomSheet ? 0 : 1000)
        .offset(y: bottomState.height)
        .blur(radius: show ? 20 : 0)
        .animation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.8))
        .gesture(
            DragGesture().onChanged { value in
                self.bottomState = value.translation
                if self.showFull {
                    self.bottomState.height += -300
                }
                if self.bottomState.height < -300 {
                    self.bottomState.height = -300
                }
            }
            .onEnded { value in
                if self.bottomState.height > 50 {
                    data.showbottomSheet = false
                }
                if (self.bottomState.height < -100 && !self.showFull) || (self.bottomState.height < -250 && self.showFull) {
                    self.bottomState.height = -300
                    self.showFull = true
                } else {
                    self.bottomState = .zero
                    self.showFull = false
                }
            }
        )
        .onChange(of: codepin) { value in
            if value.count <= 5 {
                data.pinCode =  Int(value)
            } else {
                codepin = String(data.pinCode!)
            }
        }
    }
    
    private func storeInput() -> Binding<String>{
        switch edition {
        case .amount:
            return $data.purchaseDetail.amount.stringBind
        case .code:
            return $codepin
        default:
            return .constant("")
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

