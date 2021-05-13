//
//  NewDialingView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 13/05/2021.
//

import SwiftUI

struct NewDialingView: View {
    @State private var composedCode: String = ""
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()

                if !composedCode.isEmpty {
                    LinearGradient(gradient: Gradient(colors: [Color.red, Color.blue]), startPoint: .leading, endPoint: .trailing)
                        .frame(maxWidth: .infinity)
                        .frame(height: 30)
                        .mask(Text(composedCode))
                        .font(Font.title.bold())
                }
                PinView(input: $composedCode.animation(), btnSize: .init(width: 80, height: 80))
                    .font(Font.title2.bold())
                Button(action: {
                    
                }, label: {
                    Image(systemName: "phone.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .foregroundColor(.primary)
                })
            }
            .padding(.bottom, 20)
            .navigationTitle("Incognito Mode👨🏽‍💻𒆂")
        }
    }
}

struct NewDialingView_Previews: PreviewProvider {
    static var previews: some View {
        NewDialingView()
    }
}

