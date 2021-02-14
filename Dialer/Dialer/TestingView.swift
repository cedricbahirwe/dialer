//
//  TestingView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 14/02/2021.
//

import SwiftUI

struct TestingView: View {
    @State private var showPinView = true
    var body: some View {
        VStack {
            Text("Enter Your PIN")
                .font(.system(.title, design: .rounded))
                .fontWeight(.bold)
            GeometryReader { proxy in
                PassCodeCodeView(viewWidth: proxy.size.width/5) { passCode in
                    print(passCode)
                }
            }
            .frame(height: 85)
        }
        .frame(height: 150)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 3)
        .padding()
        .offset(y: showPinView ? 0 : 1200)
        .animation(.interpolatingSpring(stiffness: 300.0, damping: 30.0, initialVelocity: 10.0))
    }
}

struct TestingView_Previews: PreviewProvider {
    static var previews: some View {
        TestingView()
    }
}
