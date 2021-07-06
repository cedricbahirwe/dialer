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
    private let currentDate = Date()
    @State private var didCopyToClipBoard = false
    var body: some View {
        ZStack {
            Color(.secondarySystemBackground)
            CongratsView()
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
                    .animation(.default)
                }
                Group {
                    Text("Remaining time: ")
                    + Text(currentDate.addingTimeInterval(10), style: .relative)
                }
                .font(Font.callout.weight(.semibold))
                .foregroundColor(Color.red.opacity(0.8))

            }
            .padding(20)
            .frame(width: width-20)
            .background(
                Color(.systemBackground)
            )
            .cornerRadius(10)
        }
        .ignoresSafeArea()
        .onAppear() {
            DispatchQueue.main.asyncAfter(deadline: .now()+9) {
                withAnimation {
                    isPresented = false
                }
            }
        }
    }
    
    private func sendMail() {
//        let googleUrlString = "googlegmail:///co?to=\(email)&subject=Dialer%20Monthly%20Award"
        let mailUrlString = URL(string: "mailto:\(email)")!
        
        if UIApplication.shared.canOpenURL(mailUrlString) {
            UIApplication.shared.open(mailUrlString, options: [:], completionHandler: nil)
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
    }
}

