//
//  WrappedViewTwo.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 28/12/2024.
//  Copyright © 2024 Cédric Bahirwe. All rights reserved.
//

import SwiftUI

struct WrappedViewTwo: View {
    @State private var offset: CGFloat = 0
    @State private var navigateToNextPage = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    ForEach(0..<20, id: \.self) { _ in
                        HStack(spacing: 0) {
                            ForEach(["55,139", "55,139", "55,139"], id: \.self) { text in


                                Text(text)
                                    .background(getRandomColors())
                                    .font(.system(size: 110, weight: .bold))
                                    .foregroundColor(getRandomColor())
                                    .frame(width: geometry.size.width)
                            }
                        }
                    }
//                    NavigationLink(destination: WrappedViewThree(), isActive: $navigateToNextPage) {
//                                      EmptyView()
//                                  }
                }
                .offset(y: offset)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
                                  navigateToNextPage = true
                              }
                    let totalHeight = geometry.size.height
                    let duration = 5.0 // Adjust rolling duration

                    withAnimation(Animation.linear(duration: duration).repeatForever(autoreverses: false)) {
                        offset = -totalHeight
                    }
                }
            }
//            .navigationBarBackButtonHidden(true)
        }
    }

    // Random color generator
    private func getRandomColor() -> Color {
        let colors: [Color] = [.yellow, .red ,.purple]
        return colors.randomElement()!
    }

    private func getRandomColors() -> Color {
        let colors: [Color] = [.black,.green]
        return colors.randomElement()!
    }
}

#Preview {
    WrappedViewTwo()
}
