//
//  WrappedViewOne.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 28/12/2024.
//  Copyright © 2024 Cédric Bahirwe. All rights reserved.
//

import SwiftUI

struct WrappedViewOne: View {
    let numberOfTransactions: Int

    @State private var animateShapes = false

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.yellow,.purple, .orange.opacity(0.8)]),
                startPoint: .top,
                endPoint: .trailing
            ).ignoresSafeArea()

            ZStack {
                ForEach(0..<5) { index in
                    RoundedRectangle(cornerRadius: 30)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.pink, Color.red]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: CGFloat(200 + index * 40), height: CGFloat(300 + index * 60))
                        .offset(y: animateShapes ? -150 : 150)
                        .rotationEffect(.degrees(Double(index) * 15))
                        .opacity(0.3 + (0.15 * Double(5 - index)))
                        .animation(
                            Animation.easeInOut(duration: 3)
                                .repeatForever(autoreverses: true),
                            value: animateShapes
                        )
                }
            }
            .task {
                animateShapes = true
            }

            VStack(spacing: 10) {
                VStack(spacing: 12) {
                    Text("Hi Dialer")
                        .font(.system(.title, design: .rounded, weight: .black))
                        .foregroundStyle(.white)

                    Text("Wrapped's ready!")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.yellow)
                        .multilineTextAlignment(.center)
                }

                Divider()
                    .background(.white)

                VStack(alignment: .leading, spacing: 0) {
                    Text("Your made ^[\(numberOfTransactions) transaction](inflect: true) this year 🎉🎉🎉")
                        .font(.system(.largeTitle, weight: .bold))
                        .multilineTextAlignment(.center)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
            }
            .padding()
            .background(.black.opacity(0.5), in: .rect(cornerRadius: 20))
            .background(.thinMaterial, in: .rect(cornerRadius: 20))
            .padding(.horizontal, 20)

        }
    }
}
#Preview {
    WrappedViewOne(numberOfTransactions: 10)
}
