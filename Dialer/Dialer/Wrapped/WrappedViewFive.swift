//
//  WrappedViewFive.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 28/12/2024.
//  Copyright © 2024 Cédric Bahirwe. All rights reserved.
//

import SwiftUI

let deval = false

struct WrappedViewFive: View {
    @State private var showText = deval
    @State private var showList = deval
    @State private var showdelay = false

    var body: some View {
        ZStack {
            AnimatedBackground()

            VStack(alignment: .leading) {
                if showText {
                    Text("Your spendings")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .cornerRadius(10)
                        .transition(.scale)
                        .animation(.easeIn(duration: 1), value: showText)
                        .padding(.horizontal)
                }

                // Top Songs List
                if showList {
                    VStack(alignment: .leading, spacing: 25) {
                        ForEach(spendings.indices, id: \.self) { index in
                            HStack(spacing: 16) {

                                Text("\(index + 1)")
                                    .font(.system(.largeTitle, design: .monospaced, weight: .black))

                                Divider()
                                    .frame(maxHeight: 100)

                                VStack(alignment: .leading) {
                                    Text(spendings[index].title)
                                        .font(.title2.bold())

                                    Text(spendings[index].amount.formatted(.currency(code: "RWF")))
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }

                                Spacer()

                                Text(spendings[index].percentage.formatted(.percent.precision(.fractionLength(1))))
                                    .font(.system(.title, design: .serif, weight: .heavy))
                            }
                            .padding()
                            .background(.thinMaterial, in: .rect(cornerRadius: 20))
                            .shadow(color: .lightShadow, radius: 10)
                            .transition(.move(edge: .leading))
                            .offset(y: !showdelay ? -CGFloat(index) * 100 : 0)
//                            .transition(.asymmetric(insertion: .slide, removal: .scale))
//                            .animation(.easeInOut(duration: 1.2), value: showList)
//                            .opacity(showList ? 1 : 0)
                        }
                    }
                    .padding()
                }
            }
        }
        .frame(maxWidth: .infinity)
        .foregroundStyle(.white)
        .task {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    showText = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.25) {
                withAnimation(.spring()) {
                    showList = true
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.75) {
                withAnimation(.bouncy(extraBounce: 0.2)) {
                    showdelay = true
                }
            }
        }
    }
}

#Preview {
    WrappedViewFive()
}
struct SpendingSummary {
    let title: String
    let amount: Int
    let percentage: Double
}

let spendings: [SpendingSummary] = [
    .init(title: "User", amount: 15000, percentage: 0.492),
    .init(title: "Airtime", amount: 15000, percentage: 0.419),
    .init(title: "Merchant", amount: 2400, percentage: 0.890)
]

struct AnimatedBackground: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            ForEach(0..<5) { i in
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.red, .yellow, .blue]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: CGFloat(100 + (i * 50)), height: CGFloat(300 + (i * 50)))
                    .offset(x: animate ? 150 : -150, y: animate ? -150 : 150)
                    .opacity(0.3)
                    .blur(radius: animate ? 8 : 0)
                    .animation(
                        Animation.easeInOut(duration: 4)
                            .repeatForever(autoreverses: true),
                        value: animate
                    )
            }
        }
        .task {
            animate.toggle()
        }
    }
}
