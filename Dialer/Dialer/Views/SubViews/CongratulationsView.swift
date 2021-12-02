//
//  CongratulationsView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 05/07/2021.
//

import SwiftUI

struct CongratulationsView: View {
    @Binding var isPresented: Bool
    private let width = UIScreen.main.bounds.size.width
    private let email = "abc.incs.001@gmail.com"

    @State private var didCopyToClipBoard = false    
    @State private var timeRemaining: Int = 71
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var isAppActive = true

    var body: some View {
        ZStack {
            Color(.secondarySystemBackground)
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
                Text("Thanks for using Dialer for the past month!")
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .opacity(0.8)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
               
                Text("Please take a screenshot of this screen and send it to the following email to receive your award.")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                
                HStack {
                    Button(email, action: sendMail)
                    Button(action:copyToClipBoard) {
                        if didCopyToClipBoard {
                            Image(systemName: "checkmark")
                                .foregroundColor(.green)
                        } else {
                        Image(systemName: "doc.on.clipboard.fill")
                            .imageScale(.small)
                        }
                    }
                }
                Text(String(format: NSLocalizedString("Remaining time: timeRemaining seconds", comment: ""), timeRemaining))
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.red.opacity(0.8))
            }
            .padding(20)
            .frame(width: width-20)
            .background(
                Color(.systemBackground)
            )
            .cornerRadius(10)
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
    
    private func sendMail() {
        
        let mailUrl = URL(string: "mailto:\(email)?subject=Dialer%20Monthly%20Award!")!
        
        if UIApplication.shared.canOpenURL(mailUrl) {
            UIApplication.shared.open(mailUrl)
        }
        copyToClipBoard()
    }
    
    private func copyToClipBoard() {
        UIPasteboard.general.string = email
        didCopyToClipBoard = true
        DispatchQueue.main.asyncAfter(deadline: .now()+3) {
            didCopyToClipBoard = false
        }
    }
}

struct CongratulationsView_Previews: PreviewProvider {
    static var previews: some View {
        CongratulationsView(isPresented: .constant(true))
            .environment(\.locale, .init(identifier: "en"))
    }
}

