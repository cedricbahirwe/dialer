//
//  TestingView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 13/04/2022.
//

import SwiftUI

struct TestingView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color("background"))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
            RoundedRectangle(cornerRadius: 20)
                .fill(Color("background"))
                .frame(width: 300, height: 180)
                .shadow(color: Color("lightShadow"), radius: 8, x: -8, y: -8)
                .shadow(color: Color("darkShadow"), radius: 8, x: 8, y: 8)
        }
    }
}

struct TestingView_Previews: PreviewProvider {
    static var previews: some View {
        TestingView()
            .preferredColorScheme(.dark)
    }
}
