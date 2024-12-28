//
//  WrappedViewFour.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 28/12/2024.
//  Copyright © 2024 Cédric Bahirwe. All rights reserved.
//

import SwiftUI

struct WrappedViewFour: View {

    @State private var animateShapes = false
    @State private var navigateToNextPage = false
    var body: some View {
        ZStack {
            // Background
            GeometryReader { geometry in
                ZStack {
                         // Background: Purple gradient with circular layers
                         AngularGradient(gradient: Gradient(colors: [.green, .green.opacity(0.6), .green.opacity(0.3)]),
                                         center: .center)
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
                         .stroke(LinearGradient(gradient: Gradient(colors: [.green, .green.opacity(0.8)]),
                                                startPoint: .leading,
                                                endPoint: .trailing),
                                 style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                         .offset(x: 80, y: 0)

                     }
                .navigationBarBackButtonHidden(true)

//                ZStack {
//                    RoundedRectangle(cornerRadius: 0)
//                        .fill(
//                            LinearGradient(
//                                gradient: Gradient(colors: [Color.yellow, Color.red]),
//                                startPoint: .top,
//                                endPoint: .bottom
//                            )
//                        )
//                        .frame(maxWidth: .infinity,maxHeight: .infinity)
//                        .ignoresSafeArea()
//
//                    // Gradient background layers
//                    VStack {
//                        Spacer()
//
//                        ForEach(0..<15) { index in
//                            AngularGradient(
//                                gradient: Gradient(colors: [ Color.purple, Color.yellow]),
//                                center: .center
//                            )
////                            .frame(width: geometry.size.width * 1.2, height: geometry.size.height / 2)
//                            .clipShape(CustomWaveShape())
//                            .rotationEffect(.degrees(50))
////                            .padding(.bottom,50)
//                                .frame(width: CGFloat(200 + index * 40), height: CGFloat(300 + index * 60))
//                                .offset(y: animateShapes ? -350 : 50)
//                                .rotationEffect(.degrees(Double(index) * 15))
//                               // .opacity(0.3 + (0.15 * Double(5 - index)))
//                                .animation(
//                                    Animation.easeInOut(duration: 5)
//                                        .repeatForever(autoreverses: true),
//                                    value: animateShapes
//                                )
//                        }
//
//
//
////                        ZStack {
////                            AngularGradient(
////                                gradient: Gradient(colors: [Color.blue, Color.purple, Color.yellow]),
////                                center: .center
////                            )
////                            .frame(width: geometry.size.width * 1.2, height: geometry.size.height / 2)
////                            .clipShape(CustomWaveShape())
////                            .rotationEffect(.degrees(135))
////                            .padding(.bottom,50)
////                        }
////                        Spacer()
////                        Spacer()
////                        ZStack {
////                            AngularGradient(
////                                gradient: Gradient(colors: [Color.blue, Color.purple, Color.yellow]),
////                                center: .center
////                            )
////                            .frame(width: geometry.size.width * 1.2, height: geometry.size.height / 2)
////                            .clipShape(CustomWaveShape())
////                            .rotationEffect(.degrees(-10))
////                            .padding(.bottom,50)
////                        }
//                    }
//                    .onAppear {
//                        animateShapes.toggle()
//                    }
//                }
            }

            // Foreground
            VStack {
                Spacer()

                // Album Artwork
                Image("goat") // Replace with your image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .cornerRadius(8)
                    .shadow(radius: 10)

                Spacer()

                // Text Overlay
                VStack(spacing: 10) {
                    Text("Favourite Song in 2024")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)

                    Text("Whistle Podu (From \"The Greatest of all Time\")")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black)
                        .padding(.horizontal, 20)

                    Text("Thalapthy Vijay")
                        .font(.subheadline)
                        .foregroundColor(.black.opacity(0.7))
//
//                    Text("Total Streams")
//                        .font(.headline)
//                        .foregroundColor(.black)
//
//                    Text("62")
//                        .font(.largeTitle)
//                        .fontWeight(.bold)
//                        .foregroundColor(.black)

                    Text("Top 80% of listeners in india")
                        .font(.footnote)
                        .foregroundColor(.black.opacity(0.6))
                }
                .padding()

                Spacer()

                // Spotify Branding
                Text("SPOTIFY.COM/WRAPPED")
                    .font(.caption)
                    .foregroundColor(.black.opacity(0.6))

//                NavigationLink(destination: WrappedViewFive(), isActive: $navigateToNextPage) {
//                                  EmptyView()
//                              }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                              navigateToNextPage = true
                          }

                }
            }
        }
    }

#Preview {
    WrappedViewFour()
}
