//
//  DashBoardView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 04/04/2021.
//

import SwiftUI

struct DashBoardView: View {
    @EnvironmentObject private var data: MainViewModel
    
    @AppStorage(UserDefaultsKeys.showWelcomeView)
    private var showWelcomeView: Bool = true
    
    @AppStorage(UserDefaultsKeys.allowBiometrics)
    private var allowBiometrics = false
    
    @State private var presentTransferView = false
    @State private var showPurchaseSheet = false
        
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                VStack(spacing: 29) {
                    HStack(spacing: 20) {
                        DashItemView(
                            title: "Buy airtime",
                            icon: "wallet.pass")
                        .onTapGesture {
                            withAnimation {
                                showPurchaseSheet = true
                                Tracker.shared.logEvent(.airtimeOpened)
                            }
                        }
                        
                        DashItemView(
                            title: "Transfer/Pay",
                            icon: "paperplane.circle")
                        .onTapForBiometrics {
                            presentTransferView = $0
                            Tracker.shared.logEvent(.transferOpened)
                        }
                    }
                    
                    HStack(spacing: 15) {
                        DashItemView(
                            title: "History",
                            icon: "clock.arrow.circlepath")
                        .onTapGesture {
                            data.showHistoryView()
                        }
                        
                        NavigationLink {
                            MySpaceView()
                        } label: {
                            DashItemView(
                                title: "My Space",
                                icon: "person.crop.circle.badge")
                            .onAppear() {
                                Tracker.shared.logEvent(.mySpaceOpened)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
                
                NavigationLink(isActive: $presentTransferView) {
                    TransferView()
                } label: { EmptyView() }
                
                Spacer()
            }
            .blur(radius: showPurchaseSheet ? 1 : 0)
        }
        .sheet(isPresented: $showPurchaseSheet) {
            PurchaseDetailView(
                isPresented: $showPurchaseSheet,
                data: data
            )
            .presentationDetents([.height(400)])
        }
        .sheet(isPresented: $showWelcomeView) {
            WhatsNewView(isPresented: $showWelcomeView)
        }
        .sheet(item: $data.presentedSheet) { sheet in
            switch sheet {
            case .settings:
                SettingsView()
                    .environmentObject(data)
            case .history:
                DialingsHistoryView(data: data.history)
            }
        }
        .background(Color.primaryBackground)
        .navigationTitle("Dialer")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if allowBiometrics {
                    gearGradient
                        .onTapForBiometrics {
                            if $0 {
                                data.showSettingsView()
                            }
                        }
                } else {
                    Button(action: data.showSettingsView) { gearGradient }
                }
            }
        }
        .trackAppearance(.dashboard)
    }
}

private extension DashBoardView {
    var gearGradient: some View {
        LinearGradient(gradient: Gradient(colors: [.red, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .frame(width: 30, height: 30)
            .mask(
                Image(systemName: "gear")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            )
    }
}

#Preview {
    NavigationStack {
        DashBoardView()
            .environmentObject(MainViewModel())
    }
}
