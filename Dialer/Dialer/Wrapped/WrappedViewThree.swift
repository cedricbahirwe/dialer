//
//  WrappedViewThree.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 28/12/2024.
//  Copyright © 2024 Cédric Bahirwe. All rights reserved.
//

import SwiftUI

struct WrappedViewThree: View {
    @State private var animateShapes = false

    var body: some View {
        ZStack {
            // Background
            backgroundView

            // Foreground
            VStack {
                Spacer()

                Image(.dialitApplogo) // Replace with top cateegory icon & color
                    .resizable()
                    .frame(width: 250, height: 250)
                    .cornerRadius(15)
                    .shadow(radius: 10)

                Spacer()

                // Text Overlay
                VStack(spacing: 10) {
                    Text("Your Top Category ")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.black)

                    Text("Merchant")
                        .font(.system(.largeTitle, design: .monospaced, weight: .heavy))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.black)
                        .padding(.horizontal, 20)

                    Text("Anirudh Ravichander")
                        .font(.subheadline)
                        .foregroundStyle(.black.opacity(0.7))

                    Text("Amount Spent")
                        .font(.headline)
                        .foregroundStyle(.black)

                    Text("\(62000.formatted(.currency(code: "RWF")))")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.black)

                    Text("Making \((0.517).formatted(.percent)) of your total transactions")
                        .font(.footnote)
                        .foregroundStyle(.black.opacity(0.6))
                }
                .padding()

                Spacer()

                Text("Dialer@WRAPPED")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var backgroundView: some View {
        GeometryReader { geometry in
            ZStack {
                // Background: Purple gradient with circular layers
                AngularGradient(gradient: Gradient(colors: [.yellow, .yellow.opacity(0.6), .yellow.opacity(0.3)]),
                                center: .bottom)
                .ignoresSafeArea()
                .overlay(
                    // Circular Layers
                    ForEach(0..<12) { index in
                        Circle()
                            .strokeBorder(Color.yellow.opacity(Double(index + 1) * 0.2), lineWidth: 18)
                            .frame(width: CGFloat(200 + index * 40), height: CGFloat(200 + index * 40))
                            .offset(x: -50, y: 100)
                    }

                )

                // Neon Green Zigzag Shape
                // make this pulsating???ux??
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
                        gradient: Gradient(colors: [.main, .mainRed.opacity(1)]),
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
    }
}

#Preview {
    WrappedViewThree()
}
