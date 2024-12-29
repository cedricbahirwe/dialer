//
//  WrappedViewTwo.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 28/12/2024.
//  Copyright © 2024 Cédric Bahirwe. All rights reserved.
//

import SwiftUI

struct WrappedViewTwo: View {
    let totalAmountSpent: Int
    @State private var offset: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.matteBlack.ignoresSafeArea()

                VStack(spacing: 0) {
                    ForEach(0..<25, id: \.self) { _ in
                        Text("\(totalAmountSpent)")
                            .font(.system(size: 180, weight: .bold))
                            .foregroundStyle(getRandomColor())
                            .background(getRandomBackground())
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(1)
                            .minimumScaleFactor(0.25)
                    }
                }.padding(.horizontal)
                .offset(y: offset)
                .task {
                    let totalHeight = geometry.size.height
                    let duration = 5.0 // Adjust rolling duration

                    withAnimation(
                        Animation
                            .linear(duration: duration)
                            .repeatForever(autoreverses: false)
                    ) {
                        offset = -totalHeight
                    }
                }
            }
        }
    }

    // Random color generator
    private func getRandomColor() -> Color {
        [.yellow, .red , .white].randomElement()!
    }

    private func getRandomBackground() -> Color {
        [.black, .green, .mainRed].randomElement()!
    }
}

#Preview {
    WrappedViewTwo(totalAmountSpent: 1000)
}
