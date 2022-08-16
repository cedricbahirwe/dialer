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
            //            Color.primaryBackground.ignoresSafeArea()
            VStack  {
                Menu("Options") {
                    Button("Order Now", action: placeOrder)
                    Button("Adjust Order", action: adjustOrder)
                    Button("Cancel", action: cancelOrder)
                }
            }
        }
        .padding()
    }

    func placeOrder() { }
    func adjustOrder() { }
    func cancelOrder() { }
}

struct TestingView_Previews: PreviewProvider {
    static var previews: some View {
        TestingView()
        //            .preferredColorScheme(.dark)
    }
}
