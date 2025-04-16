//
//  WrappedViewThree.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 28/12/2024.
//  Copyright © 2024 Cédric Bahirwe. All rights reserved.
//

import SwiftUI

struct WrappedViewThree: View {
    let categoryName: String
    let amountSpent: Int
    let percentage: Double
    let imageName: String
    let color: Color

    var body: some View {
        ZStack {
            // Background
            backgroundView

            // Foreground
            VStack {
                Spacer()

                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .padding(50)
                    .frame(width: 250, height: 250)
                    .background(color)
                    .clipShape(.rect(cornerRadius: 15))
                    .shadow(radius: 10)
                    .foregroundStyle(.white)

                Spacer()

                // Text Overlay
                VStack(spacing: 10) {
                    Text("Your Top Category ")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.black)

                    Text(categoryName)
                        .font(.system(.largeTitle, design: .monospaced, weight: .heavy))
                        .foregroundStyle(.black)

                    Text("Amount Spent")
                        .font(.headline)
                        .foregroundStyle(.black)

                    Text("\(amountSpent.formatted(.currency(code: "RWF")))")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.black)

                    Text("Making **\((percentage).formatted(.percent.precision(.fractionLength(1))))** of your total transactions")
                        .font(.footnote)
                        .foregroundStyle(.black.opacity(0.8))
                }
                .padding()

                Spacer()

                DialerWrappedFooter()
            }
        }
    }

    private var backgroundView: some View {
        ZStack {
            AngularGradient(
                gradient: Gradient(colors: [.yellow, .yellow.opacity(0.6), .yellow.opacity(0.3)]),
                center: .bottom)
            .ignoresSafeArea()
            .overlay(CircularLayers())

            ZigZagShapeView()
        }
    }
}

#Preview {
    WrappedViewThree(
        categoryName: "Merchant",
        amountSpent: 53400,
        percentage: 0.68,
        imageName: "person",
        color: .black
    )
}

struct CircularLayers: View {
    var color: Color = Color.yellow
    @State var animate = false
    var body: some View {
        ZStack {
            ForEach(0..<12) { index in
                Circle()
                    .strokeBorder(color.opacity(Double(index + 1) * 0.2), lineWidth: 18)
                    .frame(width: CGFloat(200 + index * 40), height: CGFloat(200 + index * 40))
                    .offset(x: -50, y: 100)
                    .scaleEffect(animate ? 1.5 : 1)
            }
        }
        .task {
            withAnimation(.linear(duration: TimeInterval(6)).repeatForever(autoreverses: true)) {
                self.animate.toggle()
            }
        }
    }
}


// Neon Green Zigzag Shape
// make this pulsating???ux??
struct ZigZagShapeView: View {
    var gradient: Gradient = Gradient(colors: [.main, .mainRed.opacity(1)])
    var body: some View {
        Path { path in
            // Start point
            path.move(to: CGPoint(x: 10, y: 50))
            // Zigzag points
            path.addLine(to: CGPoint(x: 40, y: 100))
            path.addLine(to: CGPoint(x: 60, y: 250))
            path.addLine(to: CGPoint(x: 80, y: -60))
            path.addLine(to: CGPoint(x: 100, y: 300))
            path.addLine(to: CGPoint(x: 120, y: 100))
            path.addLine(to: CGPoint(x: 140, y: -100))
            path.addLine(to: CGPoint(x: 160, y: 100))
            path.addLine(to: CGPoint(x: 180, y: 350))
            path.addLine(to: CGPoint(x: 200, y: -40))
            path.addLine(to: CGPoint(x: 220, y: 450))
            path.addLine(to: CGPoint(x: 240, y: 100))
            path.addLine(to: CGPoint(x: 260, y: 250))
            path.addLine(to: CGPoint(x: 280, y: -40))
            path.addLine(to: CGPoint(x: 300, y: 450))
            path.addLine(to: CGPoint(x: 320, y: 100))

        }
        .stroke(
            LinearGradient(
                gradient: gradient,
                startPoint: .leading,
                endPoint: .trailing
            ),
            style: StrokeStyle(
                lineWidth: 20,
                lineCap: .round,
                lineJoin: .round
            )
        )
        .offset(x: 80)
    }
}
