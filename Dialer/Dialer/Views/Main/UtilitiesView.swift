//
//  UtilitiesView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 19/11/2021.
//

import SwiftUI

struct UtilitiesView: View {
    @EnvironmentObject private var store: MainViewModel
        
    var body: some View {
        List {
            
            Section("Primary") {
                NavigationLink {
                    ElectricityView()
                } label: {
                    Text("Buy Electricity")
                }
                
                TappeableText("Check Momo Balance", onTap: store.checkMobileWalletBalance)
            }
            
            Section("Secondary") {
                
                TappeableText("Check Airtime Balance", onTap: store.checkAirtimeBalance)
                
                TappeableText("Check Internet Bundles", onTap: store.checkInternetBalance)
                
                
                NavigationLink {
                    VoicePacksView()
                        
                } label: {
                    Text("Buy Voice Packs")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .overlay(ComingSoonLabel(), alignment: .trailing)
                }
                .disabled(true)
                
                TappeableText("Check Voice Packs Balance", onTap: store.checkVoicePackBalance)
                
                TappeableText("Check my number", onTap: store.checkSimNumber)
            }
        }
        .navigationTitle("Utilities")
        
    }
}

struct UtilitiesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UtilitiesView()
                
        }.environmentObject(MainViewModel())
    }
}

struct TappeableText: View {
    init(_ title: String, onTap action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    let title: String
    var action: () -> Void
    var body: some View {
        Text(title)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture(perform: action)
    }
}