//
//  NewDialingView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 13/05/2021.
//

import SwiftUI

struct NewDialingView: View {
    @State private var composedCode: String = ""
    @State private var showInValidMsg: Bool = false
    @Environment(\.presentationMode)
    private var presentationMode
    
    var body: some View {
        VStack(spacing: 10) {
            Image("dialit.applogo")
                .resizable()
                .scaledToFit()
                .frame(width: 65)
            
            VStack(spacing: 10) {
                Group {
                    Text("Invalid code. Check it and try again.")
                        .font(.system(size: 16))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.5)
                        .opacity(showInValidMsg ? 1 : 0)
                        
                    LinearGradient(gradient: Gradient(colors: [Color.red, Color.blue]), startPoint: .leading, endPoint: .trailing)
                        .frame(height: 32)
                        .mask(Text(composedCode))
                        .font(.title)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .truncationMode(.head)
                        .padding(.horizontal, 20)
                        .opacity(composedCode.isEmpty ? 0 : 1)
                }
                
                PinView(input: $composedCode.animation(),
                        isFullMode: true, btnSize: 80)
                    .font(.title.bold())
                    .padding(.vertical, 10)
                    .padding()
                
                Button(action: {
                    dial(composedCode)
                }, label: {
                    Image(systemName: "phone.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 75, height: 75)
                        .clipShape(Circle())
                        .foregroundColor(.accentColor)
                })
                .frame(maxWidth: .infinity)
                .overlay(bottomNavigationView)
                Spacer()
            }
            
        }
        .preferredColorScheme(.dark)
        
    }
    
    private func dial(_ code: String) {
        // Basic Checks
        // This can be removed when user wants to dial a phone number ....
        if code.contains("*") && code.contains("#") && code.count >= 5 {
            if let telUrl = URL(string: "tel://\(code)"), UIApplication.shared.canOpenURL(telUrl) {
                UIApplication.shared.open(telUrl, options: [:], completionHandler: { _ in})

            } else {
                // Can not dial this code
                manageInvalidCode()
            }
            
        } else {
            // Supposed to be invalid, Can not dial this code
            manageInvalidCode()
        }
    }
    
    private func manageInvalidCode() {
        showInValidMsg = true
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            showInValidMsg = false
        }
    }
    
    private var bottomNavigationView: some View {
        HStack {
            
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Image(systemName: "arrow.backward.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(10)
                    .frame(width: 55, height: 55)
            })
            .frame(width: 75, height: 75)
            Spacer()
            Button(action: {
                if !composedCode.isEmpty {
                    composedCode.removeLast()
                }
            }, label: {
                Image(systemName: "delete.left.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(10)
                    .frame(width: 55, height: 55)
            })
            .frame(width: 75, height: 75)
            .opacity(composedCode.isEmpty ? 0 : 1)
        }
        .padding(.horizontal, 25)
        .foregroundColor(Color.red.opacity(0.8))
    }
}

struct NewDiallingView: View {
    var body: some View {
        VStack(spacing: 10) {
            Image("dialit.applogo")
                .resizable()
                .scaledToFit()
                .frame(width: 65)
                .cornerRadius(14)

            VStack(spacing: 10) {
                Group {
                    Text("Invalid code. Check it and try again.")
                        .font(.system(size: 16))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.5)
//                        .opacity(showInValidMsg ? 1 : 0)
                    TextField("", text: .constant(""))
                        .padding(10)
                        .background(Color.init("offBackground"))
                        .cornerRadius(15)
                        .padding(.horizontal, 20)
                        .shadow(radius: 0.4)
                    LinearGradient(gradient: Gradient(colors: [Color.red, Color.blue]), startPoint: .leading, endPoint: .trailing)
                        .frame(height: 32)
                        .font(.title)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .truncationMode(.head)
                        .padding(.horizontal, 20)
                }

                PinView(input: .constant("").animation(),
                        isFullMode: true, btnSize: 80)
                    .font(.title.bold())
                    .padding(.vertical, 10)
                    .padding()

                Button(action: {
//                    dial(composedCode)
                }, label: {
                    Image(systemName: "phone.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 75, height: 75)
                        .clipShape(Circle())
                        .foregroundColor(.accentColor)
                })
                .frame(maxWidth: .infinity)
//                .overlay(bottomNavigationView)
                Spacer()
            }


        }
    }
}

struct NewDialingView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            NewDiallingView()
//            NewDialingView()
        }
//        .previewLayout(.fixed(width: 850, height: 900))
    }
}

