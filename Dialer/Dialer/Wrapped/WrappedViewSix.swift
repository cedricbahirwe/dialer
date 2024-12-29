//
//  WrappedViewSix.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 28/12/2024.
//  Copyright © 2024 Cédric Bahirwe. All rights reserved.
//

import SwiftUI

struct WrappedViewSix: View {
    var body: some View {
        ZStack {
            // Background color
            RoundedRectangle(cornerRadius: 30)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black, Color.black]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            // Starburst spikes
            ZStack {

                ForEach(0..<20) { index in
                    StarSpike()
                        .fill(Color.purple )
                        .frame(width: 400, height: 800)
                        .rotationEffect(.degrees(Double(index) * 35))
                }
                ForEach(0..<20) { index in
                    StarSpike()
                        .fill( Color.orange)
                        .frame(width: 350, height: 600)
                        .rotationEffect(.degrees(Double(index) * 30))
                }
                GeometryReader { geometry in
                    let size = geometry.size.width * 1.05// Adjust the diamond size
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.yellow)
                        .frame(width: size, height: size)
                        .rotationEffect(.degrees(30))
                        .overlay(
                            VStack {
                                Text("From sunrise to sunset, you kept it interesting.")

                                    .font(.system(size: 25, weight: .bold))
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.center)
                                    .padding()
                                    .padding(.trailing,30)
                                    .padding(.bottom,10)


                                Text("Thanks for coming along for the ride. Untill we meet again...")

                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.black)
                                    .padding(.trailing,30)
                                    .padding(.bottom,10)

                            }
                                .padding()
                        )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top,250)
                .padding(.leading,30)

            }
        }
        .navigationBarBackButtonHidden(true)
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
