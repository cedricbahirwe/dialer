//
//  CongratulationsView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 05/07/2021.
//

import SwiftUI

struct CongratulationsView: View {
    private let width = UIScreen.main.bounds.size.width
    var body: some View {
        ZStack {
//            CongratsView()
            Color(.secondarySystemBackground)
            VStack {
                
                Image("congrats")
                    .resizable()
                    .scaledToFit()
                Text("Thanks for using Dialer for the past month!")
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .opacity(0.8)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(Date(), formatter: DateFormatter())
                Text(Date()...Date().addingTimeInterval(600))
                Text(Date(), style: .date)
                Text(Date().addingTimeInterval(60), style: .relative)
            }
            .padding(20)
            .frame(width: width-20, height: width*0.6)
            .background(
                Color(.systemBackground)
            )
            .cornerRadius(10)
        }
    }
}

struct CongratulationsView_Previews: PreviewProvider {
    static var previews: some View {
        CongratulationsView()
    }
}

