//
//  MySpaceView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 19/11/2021.
//  Update by Cédric Bahirwe on 16/08/2022.
//

import SwiftUI

struct MySpaceView: View, UtilitiesDelegate {
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
                    Text("Most Popular")
                    Spacer()
                    CopiedUSSDLabel()
                        .opacity(didCopyToClipBoard ? 1 : 0)
                }
            }
            .listRowBackground(rowBackground)

            if !store.ussdCodes.isEmpty {
                Section("Other") {
                    ForEach(store.ussdCodes) { code in
                        TappeableText(LocalizedStringKey(code.title)) {
                            MainViewModel.performQuickDial(for: .other(code.ussd))
                        }
                    }
                    .onDelete(perform: store.deleteUSSD)
                }
                .listRowBackground(rowBackground)
            }
        }
        .background(Color.primaryBackground)
        .navigationTitle("My Space")
        .sheet(isPresented: $presentNewDial) {
            NewDialingView(store: store)
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
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

struct MySpaceView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MySpaceView()
                .environmentObject(MainViewModel())
//                .preferredColorScheme(.dark)
        }
    }
}
