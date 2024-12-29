//
//  WrappedViewFive.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 28/12/2024.
//  Copyright © 2024 Cédric Bahirwe. All rights reserved.
//

import SwiftUI

struct WrappedViewFive: View {
    @State private var showText = false
    @State private var showList = false
    @State private var animatedBackground = false
    @State private var navigateToNextPage = false
    var body: some View {

        ScrollView {
            ZStack {
                // Background Animation
                AnimatedBackground()
                    .ignoresSafeArea()

//                VStack {
//                    Spacer()
//
//                    // Main Text with Animation
//                    if showText {
//                        Text("Your spendings")
//                            .font(.largeTitle)
//                            .fontWeight(.bold)
//                            .foregroundColor(.black)
//                            .multilineTextAlignment(.center)
//                            .padding(.top,25)
//                        //                        .background(Color.yellow.opacity(0.7))
//                            .cornerRadius(10)
//                            .transition(.scale)
//                            .animation(.easeIn(duration: 1), value: showText)
//                    }
//
//
//
//                    // Top Songs List
//                    if showList {
//                        VStack(alignment: .leading, spacing: 10) {
//                            //                        Text("Your Top Songs 2024")
//                            //                            .font(.title)
//                            //                            .fontWeight(.bold)
//                            //                            .foregroundColor(.black)
//
//                            ForEach(topSongs.indices, id: \.self) { index in
//                                HStack {
//                                    Text("\(index + 1)")
//                                        .font(.title3)
//                                        .fontWeight(.bold)
//                                        .foregroundColor(.black)
//
//                                    VStack(alignment: .leading) {
//                                        Text(topSongs[index].title)
//                                            .font(.headline)
//                                            .foregroundColor(.black)
//                                        Text(topSongs[index].artist)
//                                            .font(.subheadline)
//                                            .foregroundColor(.gray)
//                                    }
//                                    Spacer()
//                                    Image(topSongs[index].imgess) // Replace with your image
//                                        .resizable()
//                                        .scaledToFit()
//                                        .frame(width: 80, height: 80)
//                                        .cornerRadius(8)
//                                        .shadow(radius: 10)
//                                }
//
//                                .padding()
//                                .background(Color.yellow.opacity(1.5))
//                                .cornerRadius(20)
//                                .transition(.slide)
//                                .animation(.easeInOut(duration: 1.2), value: showList)
//                            }
//                        }  .padding()
//                            .background(Color.white)
//                            .cornerRadius(8)
//
//                    }
//
//                    Spacer()
//
//                    // Share Button
//                    Button(action: {
//                        print("Share your Wrapped story")
//                    }) {
//                        Text("Share Your Story")
//                            .fontWeight(.bold)
//                            .padding()
//                            .frame(maxWidth: .infinity)
//                            .background(Color.black)
//                            .foregroundColor(.white)
//                            .cornerRadius(8)
//                    }
//                    .padding()
//
//                    //                    NavigationLink(destination: WrappedViewSix(), isActive: $navigateToNextPage) {
//                    //                                      EmptyView()
//                    //                                  }
//                }
            }
            .task {
                DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                    navigateToNextPage = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation {
                        showText = true
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.25) {
                    withAnimation {
                        showList = true
                    }
                }
            }
        }
    }
}

#Preview {
    WrappedViewFive()
}
struct Song {
    let title: String
    let artist: String
    let imgess: String
}

let topSongs: [Song] = [
    Song(title: "Dheema (LIK)", artist: "Anirudh Ravichander", imgess: "dheema"),
    Song(title: "Ordinary person (Leo)", artist: " Anirudh Ravichander & Nikhita Gandhi", imgess: "leo"),
    Song(title: "Arabic Kuthu (Beast)", artist: "Anirudh Ravichander, Jonita Gandhi", imgess: "beast"),
    Song(title: "Neethane", artist: "Shreya Ghoshal, A.R.Rahman", imgess: "mersal"),
    Song(title: "Aathi (Kaththi)", artist: "Anirudh Ravichander, Vishal Dadlani", imgess: "kaththi"),
    Song(title: "Manasilaayo", artist: "Anirudh Ravichander", imgess: "vettaiyan")

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
                    .frame(width: CGFloat(100 + (i * 50)), height: CGFloat(100 + (i * 50)))
                    .offset(x: animate ? 150 : -150, y: animate ? -150 : 150)
                    .opacity(0.3)
//                    .blur(radius: 20)
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
