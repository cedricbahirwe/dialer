//
//  WrappedViewFour.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 28/12/2024.
//  Copyright © 2024 Cédric Bahirwe. All rights reserved.
//

import SwiftUI

struct WrappedViewFour: View {
    let activeMonth: String
    let count: Int
    var body: some View {
        ZStack {
            ZStack {
                AngularGradient(
                    gradient: Gradient(colors: [.green, .green.opacity(0.6), .green.opacity(0.3)]),
                    center: .bottom)
                .ignoresSafeArea()
                .overlay(CircularLayers())

                ZigZagShapeView(gradient: Gradient(colors: [.green, .green.opacity(0.8)]))
            }

            // Foreground
            VStack {
                Spacer()

                Image(.dialitApplogo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .cornerRadius(15)
                    .shadow(radius: 10)

                Spacer()

                VStack(spacing: 20) {
                    Text("Most Active Month")
                        .font(.title2.bold())
                        .foregroundStyle(.black)
                    
                    Text(activeMonth)
                        .font(.system(.largeTitle, design: .monospaced, weight: .heavy))
                        .foregroundStyle(.black)
                    
                    Text("You made a total of \(count) transactions that month")
                        .font(.footnote)
                        .foregroundStyle(.black.opacity(0.6))
                }
                .padding()

                Spacer()

                DialerWrappedFooter()
            }
        }
    }
}

#Preview {
    WrappedViewFour(activeMonth: "October", count: 12)
}
