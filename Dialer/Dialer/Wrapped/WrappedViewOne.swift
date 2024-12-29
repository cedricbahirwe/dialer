//
//  WrappedViewOne.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 28/12/2024.
//  Copyright © 2024 Cédric Bahirwe. All rights reserved.
//

import SwiftUI

struct WrappedViewOne: View {
    let username: String
    let numberOfTransactions: Int

    @State private var animateShapes = false
    @State private var navigateToNextPage = false

    var body: some View {
        ZStack {
            // Background Color
            LinearGradient(gradient: Gradient(colors: [.yellow,.purple, .orange.opacity(0.8)]),
                           startPoint: .top,
                           endPoint: .trailing).ignoresSafeArea()



            // Animated Shapes
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
            .onAppear {
                animateShapes.toggle()
            }

            // Center Text
            VStack(spacing: 10) {

                VStack(spacing: 12) {
                    Text("Hi @\(username)")
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .foregroundStyle(.white)

                    Text("Wrapped's ready!")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.yellow)
                        .multilineTextAlignment(.center)
                }

                Divider()
                    .background(.white)

                VStack {
                    Text("You made")
                        .font(.title3.monospaced().bold())
                        .foregroundStyle(.white)

                    VStack(alignment: .leading, spacing: 0) {
                        Text("\(numberOfTransactions)")
                            .font(.system(.title, design: .monospaced, weight: .bold))

                        Text("transactions\nthis year \(numberOfTransactions == 0 ? "" : "🎉🎉🎉")")
                            .font(.system(.largeTitle, design: .serif, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(20)
            .background(.black.opacity(0.5), in: .rect(cornerRadius: 20))
            .background(.thinMaterial, in: .rect(cornerRadius: 20))//
            .padding(.horizontal, 20)

        }
    }
}

enum WrappedRoute: Hashable {
    case one(username: String, transactionsCount: Int)
    case two(totalAmountSpent: Int)
    case  three(categoryName: String, amountSpent: Int, percentage: Double, iconName: String, color: Color)
    case four(activeMonth: String, count: Int)
    case five, six
}

#Preview {
    WrappedViewOne(username: "cedric", numberOfTransactions: 10)
}
