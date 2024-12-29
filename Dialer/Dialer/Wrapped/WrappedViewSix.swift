//
//  WrappedViewSix.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 28/12/2024.
//  Copyright © 2024 Cédric Bahirwe. All rights reserved.
//

import SwiftUI

struct WrappedViewSix: View {
    @State private var animateShapes = false
    var colors: [Color] {
        animateShapes ? [Color.black, Color.black.opacity(0.5)]  : [Color.black.opacity(0.5), Color.black]
    }

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: colors),
                startPoint: .topTrailing,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ZStack {
                ForEach(0..<20) { index in
                    StarSpike()
                        .fill(Color.white )
                        .frame(width: 400, height: 800)
                        .rotationEffect(.degrees(Double(index) * 35))
                        .scaleEffect(animateShapes ? 1 : 1.2)
                }

                ForEach(0..<20) { index in
                    StarSpike()
                        .fill(Color.mainRed.opacity(0.7))
                        .frame(width: 350, height: 600)
                        .rotationEffect(.degrees(Double(index) * 30))
                        .scaleEffect(animateShapes ? 1.5 : 1)
                }

                GeometryReader { geometry in
                    let size = geometry.size.width
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Material.thinMaterial)
                        .frame(maxWidth: size, maxHeight: size)
                        .aspectRatio(contentMode: .fit)
                        .overlay(
                            VStack {
                                Image(.dialitApplogo)
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(10)

                                Text("From sunrise to sunset,\nYou kept it interesting.")
                                    .font(.system(size: 25, weight: .bold))
                                    .multilineTextAlignment(.center)
                                    .padding(.vertical)

                                Text("Thanks for being with us.\nUntill we meet again...")
                                    .font(.system(size: 20, weight: .medium))
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(.black)

                            }
                                .padding()
                        )
                        .padding(25)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 250)
            }
        }
        .task {
            withAnimation(.easeInOut(duration: 4).repeatForever()) {
                animateShapes = true
            }
        }
    }
}

struct StarSpike: Shape {
    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height

        var path = Path()
        path.move(to: CGPoint(x: width / 2, y: 0)) // Top center
        path.addLine(to: CGPoint(x: width * 0.6, y: height * 0.6)) // Bottom right
        path.addLine(to: CGPoint(x: width * 0.4, y: height * 0.6)) // Bottom left
        path.closeSubpath()
        return path
    }
}

#Preview {
    WrappedViewSix()
}
