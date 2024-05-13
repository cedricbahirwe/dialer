//
//  ThanksYouView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 05/07/2021.
//

import SwiftUI

struct ThanksYouView: View {
    @Binding var isPresented: Bool
    @State private var timeRemaining: Int = 30
    @State private var isAppActive = true
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()
            
            VStack(spacing: 10) {
                Image("congrats")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 80)
                
                Text("Thanks for using Dialer for the past month!")
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Text("Please tell us how we can make Dialer even more useful to you.")
                    .font(.callout)
                    .multilineTextAlignment(.center)
                
                Button(action: goToAppStoreRating) {
                    Text("Rate our app")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 45)
                        .background(Color.accentColor)
                        .cornerRadius(8)
                        .foregroundStyle(.white)
                }
                
                Text("Remaining time: ^[\(timeRemaining) second](inflect: true)")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.red.opacity(0.8))
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(.primaryBackground)
            .cornerRadius(15)
            .shadow(color: .lightShadow, radius: 8, x: -8, y: -8)
            .shadow(color: .darkShadow, radius: 8, x: 8, y: 8)
            .padding()
        }
        .overlay(
            Button(action: {
                isPresented = false
            }, label: {
                Image(systemName: "multiply.circle.fill")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundStyle(.black.opacity(0.7),  .regularMaterial)
            })
            .padding()
            , alignment: .topTrailing
        )
        
        .onReceive(timer) { _ in
            guard isAppActive else { return }
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                isPresented = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            isAppActive = false
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            isAppActive = true
        }
    }
    
    private func goToAppStoreRating() {
        isPresented = false
        ReviewHandler.requestReviewManually()
    }
}

#Preview {
    ThanksYouView(isPresented: .constant(true))
}
