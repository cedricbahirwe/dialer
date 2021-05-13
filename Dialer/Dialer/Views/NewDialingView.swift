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
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                Group {
                    
                    Text("Invalid code. Check it and try again.")
                        .font(.system(size: 16))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .opacity(showInValidMsg ? 1 : 0)
                    LinearGradient(gradient: Gradient(colors: [Color.red, Color.blue]), startPoint: .leading, endPoint: .trailing)
                        .frame(height: 28)
                        .mask(Text(composedCode))
                        .font(Font.title)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .padding(.horizontal, 20)
                        .truncationMode(.head)
                        .opacity(composedCode.isEmpty ? 0 : 1)
                }
                
                PinView(input: $composedCode.animation(), fullMode: true, btnSize: .init(width: 80, height: 80))
                    .font(Font.title.bold())
                    .padding(.vertical, 10)

                Button(action: {
                    dial(composedCode)
                }, label: {
                    Image(systemName: "phone.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 78, height: 78)
                        .clipShape(Circle())
                        .foregroundColor(.primary)
                })
                .frame(maxWidth: .infinity)
                .overlay(
                    Button(action: {
                        if !composedCode.isEmpty {
                            composedCode.removeLast()
                        }
                    }, label: {
                        Image(systemName: "delete.left.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 25, alignment: .trailing)
                            .foregroundColor(Color.red.opacity(0.8))
                    })
                    .padding(30)
                    .opacity(composedCode.isEmpty ? 0 : 1)
                    ,alignment: .trailing
                )
            }
            .padding(.vertical, 15)
            .navigationTitle("Incognito Mode👨🏽‍💻𒆂")
        }
    }
    
    private func dial(_ code: String) {
        // Basic Checks
        // This can be removed when user wants to dial a phone number ....
        if code.contains("*") && code.contains("#") && code.count >= 5 {
            if let telUrl = URL(string: "tel://\(code)"), UIApplication.shared.canOpenURL(telUrl) {
                UIApplication.shared.open(telUrl, options: [:], completionHandler: { _ in
                    print("Finishinga")
                    
                })
//                UIApplication.shared.endEditing(true)

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
}

struct NewDialingView_Previews: PreviewProvider {
    static var previews: some View {
        NewDialingView()
    }
}

