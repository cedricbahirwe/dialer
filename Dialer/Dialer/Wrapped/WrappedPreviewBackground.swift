//
//  WrappedPreviewBackground.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 28/12/2024.
//  Copyright © 2024 Cédric Bahirwe. All rights reserved.
//

import SwiftUI

struct WrappedPreviewBackground: View {
    @State private var animateShapes = false

    var body: some View {
        ZStack {
            // Background Color
            LinearGradient(
                gradient: Gradient(
                    colors: [
                        .primaryBackground,
                        .offBackground,
                        .primaryBackground.opacity(
                            0.8
                        )
                    ]
                ),
                startPoint: .topLeading,
                endPoint: .trailing
            )

            // Animated Shapes
            ZStack {
                ZStack {
                    ForEach(0..<5) { index in
                        RoundedRectangle(cornerRadius: 30)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.white, Color.mainRed]),
                                    startPoint: .topTrailing,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: CGFloat(150 + index * 40), height: CGFloat(250 + index * 60))
                            .offset(y:  200)
                            .rotationEffect(.degrees(Double(index) * 15))
                            .opacity(0.3 + (0.15 * Double(5 - index)))
                        //                            .animation(
                        //                                Animation.easeInOut(duration: 3)
                        //                                    .repeatForever(autoreverses: true),
                        //                                value: animateShapes
                        //                            )
                    }
                }
                .rotationEffect(.degrees(90))
                .opacity(0)

                ZStack {
                    ForEach(0..<10) { index in
                        RoundedRectangle(cornerRadius: 30)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.mainRed, Color.primaryBackground, Color.blue]),
                                    startPoint: .topTrailing,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: CGFloat(150 + index * 40), height: CGFloat(250 + index * 60))
                            .offset(y: animateShapes ? -50 : 200)
                        //                            .rotationEffect(.degrees(animateShapes ? 360 : 0))
                            .rotationEffect(.degrees(Double(index) * 36))
                            .scaleEffect(animateShapes ? 1.5 : 1)
                            .opacity(0.3 + (0.15 * Double(5 - index)))
                            .animation(
                                Animation.easeInOut(duration: 4)
                                    .repeatForever(autoreverses: true),
                                value: animateShapes
                            )
                    }
                }
            }
        }
        .task {
            animateShapes = true
        }
    }
}

#Preview {
    WrappedPreviewBackground()
}
