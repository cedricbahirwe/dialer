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
        NavigationView {
            DashBoardView()
        }
        .onAppear(perform: setupAppearance)
        .fullScreenCover(isPresented: $data.hasReachSync) {
            CongratulationsView(isPresented: $data.hasReachSync)
        }
        .environment(\.locale, .init(identifier: "kin"))
    }
    
    private func setupAppearance() {
        
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title1).withSymbolicTraits(.traitBold)?.withDesign(UIFontDescriptor.SystemDesign.rounded)
        let descriptor2 = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle).withSymbolicTraits(.traitBold)?.withDesign(UIFontDescriptor.SystemDesign.rounded)
        
        UINavigationBar.appearance().largeTitleTextAttributes = [
            NSAttributedString.Key.font:UIFont.init(descriptor: descriptor2!, size: 34),
            NSAttributedString.Key.foregroundColor: UIColor.label,
        ]
        
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.font:UIFont.init(descriptor: descriptor!, size: 17),
            NSAttributedString.Key.foregroundColor: UIColor.label
        ]
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(MainViewModel())
    }
}
