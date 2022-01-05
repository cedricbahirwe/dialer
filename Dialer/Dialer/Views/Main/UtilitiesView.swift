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
                
                TappeableText("Check Mobile Balance", onTap: store.checkMobileWalletBalance)
                
                TappeableText("Send to my Bank Account", onTap: store.checkBankTransfer)
                
                TappeableText("Top-Up in my Mobile Wallet", onTap: store.checkBankTransfer)
                
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
