//
//  CustomViews.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 05/04/2021.
//

import SwiftUI

struct PinCodeView: View {
    @State private var showPinView = false
    @State private var securePassCode = true

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all).opacity(showPinView ? 0.6 : 0)
                .onTapGesture {
                    UIApplication.shared.endEditing(true)
                    showPinView.toggle()
                }
            VStack {
                HStack {
                    Text("Enter Your PIN")
                        .font(.system(.title, design: .rounded))
                        .fontWeight(.bold)
                    
                    Image(systemName: securePassCode ? "eye.fill" : "eye.slash.fill")
                        .imageScale(.large)
                        .onTapGesture {
                            withAnimation {
                                securePassCode.toggle()
                            }
                        }
                }
                
                
                GeometryReader { proxy in
                    PassCodeCodeView(secureFields: $securePassCode, viewWidth: proxy.size.width/5) { passCode in
                        //                                mainVM.selectedCode = mainVM.selectedDialer!.value + passCode + "#"
                        //                                mainVM.dial()
                        showPinView = false
                        
                    }
                }
                .frame(height: 85)
            }
            .frame(height: 150)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(color: Color(.label), radius: 3)
            .padding()
            .offset(y: -100)
            .offset(y: showPinView ? 0 : 1200)
            .animation(.interpolatingSpring(stiffness: 300.0, damping: 30.0, initialVelocity: 10.0))
            .zIndex(30)
        }
    }
}
