//
//  UtilitiesView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 19/11/2021.
//

import SwiftUI

struct UtilitiesView: View, UtilitiesDelegate {
    @EnvironmentObject private var store: MainViewModel
    @Environment(\.colorScheme) private var colorScheme
    @State private var didCopyToClipBoard = false
    private var rowBackground: Color {
        Color.secondary.opacity(colorScheme == .dark ? 0.1 : 0.15)
    }
    var body: some View {
        List {
            Section {
                NavigationLink {
                    ElectricityView()
                } label: {
                    Text("Buy Electricity")
                }

                TappeableText("Check Mobile Balance", onTap: store.checkMobileWalletBalance)
            } header: {
                HStack {
                    Text("Most Popular")
                    Spacer()
                    CopiedUSSDLabel()
                        .opacity(didCopyToClipBoard ? 1 : 0)
                }
            }
            .listRowBackground(rowBackground)
            
            Section("Other") {
                
                TappeableText("Check Airtime Balance", onTap: store.checkAirtimeBalance)
                
                TappeableText("Check Internet Bundles", onTap: store.checkInternetBalance)
                
                TappeableText("Check Voice Packs Balance", onTap: store.checkVoicePackBalance)
                
                TappeableText("Check my phone number", onTap: store.checkSimNumber)
            }
            .listRowBackground(rowBackground)
        }
        .background(Color.primaryBackground)
        .navigationTitle("Utilities")
        .onAppear() {
            store.utilityDelegate = self
        }
    }


    func didSelectOption(with code: DialerQuickCode) {
        copyToClipBoard(fullCode: code.ussd)
    }

    private func copyToClipBoard(fullCode: String) {
        UIPasteboard.general.string = fullCode
        withAnimation { didCopyToClipBoard = true }

        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            withAnimation {
                didCopyToClipBoard = false
            }
        }
    }
}

struct UtilitiesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UtilitiesView()
                .environmentObject(MainViewModel())
//                .preferredColorScheme(.dark)
        }
    }
}
