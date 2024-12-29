//
//  WrappedViewFive.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 28/12/2024.
//  Copyright © 2024 Cédric Bahirwe. All rights reserved.
//

import SwiftUI

struct WrappedViewFive: View {
    let spendings: [SpendingSummary]
    @State private var showTitle = false
    @State private var showSpendingList = false
    @State private var removeOffset = false

    var body: some View {
        ZStack {
            AnimatedBackground()
            
            VStack(alignment: .leading) {
                if showTitle {
                    Text("Your spendings")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .cornerRadius(10)
                        .transition(.scale)
                        .animation(.easeIn(duration: 1), value: showTitle)
                        .padding(.horizontal)
                }
                
                if showSpendingList {
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
                                        .font(.headline.weight(.medium))
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
                            .offset(y: removeOffset ? 0 : -CGFloat(index) * 100)
                        }
                    }
                    .padding()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.matteBlack)
        .foregroundStyle(.white)
        .colorScheme(.dark)
        .task {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    showTitle = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.25) {
                withAnimation(.spring()) {
                    showSpendingList = true
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.bouncy(extraBounce: 0.2)) {
                    removeOffset = true
                }
            }
        }
    }
}

#Preview {
    WrappedViewFive(spendings: spendingsExample)
}
struct SpendingSummary: Hashable {
    let title: String
    let amount: Int
    let percentage: Double
}

let spendingsExample: [SpendingSummary] = [
    .init(title: "User", amount: 15000, percentage: 0.492),
    .init(title: "Airtime", amount: 15000, percentage: 0.419),
    .init(title: "Merchant", amount: 2400, percentage: 0.089)
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
                    .offset(x: animate ? 150 : -150, y: animate ? -250 : 150)
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
