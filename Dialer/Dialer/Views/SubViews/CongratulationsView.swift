//
//  CongratulationsView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 05/07/2021.
//

import SwiftUI

struct CongratulationsView: View {
    @Binding var isPresented: Bool
    @State private var timeRemaining: Int = 71
    @State private var isAppActive = true
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()
            CongratsView()
                .opacity(timeRemaining <= 1 ? 0.3 : 1)
                .blur(radius: timeRemaining <= 1 ? 3 : 0)
                .animation(.linear(duration: 0.5), value: timeRemaining)
            VStack(spacing: 10) {
                
                Image("congrats")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 80)
                    .padding(.bottom, -10)

                Text("Thanks for using Dial It for the past month!")
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .opacity(0.8)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
               
                Text("We appreciate your support, and would like to hear how to make **Dial It** even more better.")
                    .font(.caption)
                    .multilineTextAlignment(.center)

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
                    .foregroundColor(Color.red)
                    
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
}

struct CongratulationsView_Previews: PreviewProvider {
    static var previews: some View {
        CongratulationsView(isPresented: .constant(true))
            .environment(\.locale, .init(identifier: "en"))
            .preferredColorScheme(.dark)
    }
}

