//
//  ThanksYouView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 05/07/2021.
//

import SwiftUI

struct ThanksYouView: View {
    @Binding var isPresented: Bool
    @State private var timeRemaining: Int = 70
    @State private var isAppActive = true
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var bashGradient = LinearGradient(gradient: Gradient(colors: [.yellow, .green, .purple, Color.red.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)

    var body: some View {
        ZStack {
            
            
            if #available(iOS 16.0, *) {
                Color.primaryBackground.opacity(0)
                    .background(Color.red.gradient)
                    .ignoresSafeArea()
            }
            VStack(spacing: 10) {
                
                Image("congrats")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 80)
                    .padding(.bottom, -10)

                Text("Thanks for using Dialer for the past month!")
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
               
                Text("We appreciate your support, and would love to hear how to make **Dialer** even more useful to you.")
                    .font(.callout)
                    .multilineTextAlignment(.center)
                
                Button(action: {
                    goToAppStoreRating()
                }){
                    Text("Rate our app")
                        .fontWeight(.semibold)
                        .padding(.horizontal, 10)
                        .frame(maxWidth: .infinity)
                        .frame(height: 45)
                        .background(Color.accentColor)
                        .cornerRadius(8)
                        .foregroundColor(.white)
                }

                Text(String(format: NSLocalizedString("Remaining time: timeRemaining seconds", comment: ""), timeRemaining))
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.red.opacity(0.8))
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(Color.primaryBackground)
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
                    .frame(width: 35, height: 35)
                    .foregroundStyle(.red,  .white)
                    .padding(8)
            })
            .padding(5)
            , alignment: .topLeading
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

#if DEBUG
struct CongratulationsView_Previews: PreviewProvider {
    static var previews: some View {
        ThanksYouView(isPresented: .constant(true))
//            .preferredColorScheme(.dark)
    }
}
#endif
