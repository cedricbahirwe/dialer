//
//  UtilitiesView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 19/11/2021.
//

import SwiftUI

struct UtilitiesView: View, UtilitiesDelegate {
    private enum USSDFilterOption {
        case system
        case custom
        case all
    }
    // MARK: - Environment Properties
    @EnvironmentObject private var store: MainViewModel
    @Environment(\.colorScheme) private var colorScheme

    // MARK: - Private Properties
    @State private var didCopyToClipBoard = false
    @State private var showUserCustomCodes = false
    @State private var presentNewDial = false
    @State private var filterOption: USSDFilterOption = .all

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
                    Text("Most Used")
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
        .sheet(isPresented: $presentNewDial) {
            Text("Dew Dialing")
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        filterOption = .custom
                    } label: {
                        if filterOption == .custom {
                            Label("Show my codes", systemImage: "smallcircle.circle.fill")
                        } else {
                            Label("Show my codes", image: .init())
                        }
                    }

                    Button {
                        filterOption = .all
                    } label: {
                        if filterOption == .all {
                            Label("Show all codes", systemImage: "smallcircle.circle.fill")
                        } else {
                            Label("Show all codes", image: .init())
                        }
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }

                Button {
                    presentNewDial.toggle()
                } label: {
                    Label("Add USSD Code", systemImage: "plus")
                }
            }
        }
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
