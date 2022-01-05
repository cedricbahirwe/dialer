//
//  ContentView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 08/02/2021.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var data: MainViewModel
    var body: some View {
        DashBoardView()
//            .fullScreenCover(isPresented: $data.hasReachSync) {
//                CongratulationsView(isPresented: $data.hasReachSync)
//            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(MainViewModel())
    }
}
