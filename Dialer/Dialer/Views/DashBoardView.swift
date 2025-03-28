//
//  DashBoardView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 04/04/2021.
//

import SwiftUI
import TipKit

struct DashBoardView: View {
    @Binding var navPath: [AppRoute]
    
    @EnvironmentObject private var data: MainViewModel
    @EnvironmentObject private var insightsStore: DialerInsightStore

    @AppStorage(UserDefaultsKeys.showWelcomeView)
    private var showWelcomeView: Bool = false
    
    @AppStorage(UserDefaultsKeys.allowBiometrics)
    private var allowBiometrics = false
    
    @State private var showPurchaseSheet = false
    @State private var showWrappedSheet = false
    @AppStorage(UserDefaultsKeys.appTheme) private var appTheme: DialerTheme = .system
    @Environment(\.colorScheme) private var colorScheme

    @AppStorage(UserDefaultsKeys.showUsernameSheet)
    private var showUsernameSheet = true

    var body: some View {
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
                    .onTapForBiometrics { success in
                        if success {
                            navPath.append(.transfer)
                            Tracker.shared.logEvent(.transferOpened)
                        }
                    }
                }
                
                HStack(spacing: 15) {
                    Group {
                        if #available(iOS 17.0, *) {
                            DashItemView(
                                title: "Insights",
                                icon: "lightbulb.max.fill")
                        } else {
                            DashItemView(
                                title: "History",
                                icon: "clock.arrow.circlepath")
                        }
                    }
                    .onTapGesture {
                        navPath.append(.insights)
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
            
            Spacer()

            if RemoteConfigs.shared.bool(for: .show2024Wrapped) && !insightsStore.transactionInsights.isEmpty {
                WrappedPreview(onStart: {
                    showWrappedSheet = true
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                })
                .padding()
            }
        }
        .blur(radius: showPurchaseSheet ? 1 : 0)
        .fullScreenCover(
            isPresented: $showUsernameSheet,
            onDismiss: {
                showWelcomeView = true
            }, content: {
                UserDetailsCreationView()
            }
        )
        .fullScreenCover(
            isPresented: $showWrappedSheet,
            onDismiss: {
                // Disable in local storage may be?
            }, content: {
                WrappedNavigation()
            }
        )
        .task {
            if #available(iOS 17.0, *) {
                do {
                    // try Tips.resetDatastore()
                    try Tips.configure([
                        .displayFrequency(.immediate),
                        .datastoreLocation(.applicationDefault)
                    ])
                }
                catch {
                    Log.debug("Error initializing TipKit \(error.localizedDescription)")
                }
            }
        }
        .sheet(isPresented: $showPurchaseSheet) {
            if #available(iOS 16.4, *) {
                PurchaseDetailView(
                    isPresented: $showPurchaseSheet,
                    data: data
                )
                .presentationDetents([.height(400)])
                .presentationCornerRadius(20)
            } else {
                PurchaseDetailView(
                    isPresented: $showPurchaseSheet,
                    data: data
                )
                .presentationDetents([.height(400)])
            }
        }
        .fullScreenCover(isPresented: $showWelcomeView) {
            WhatsNewView()
        }
        .sheet(item: $data.presentedSheet) { sheet in
            switch sheet {
            case .settings:
                SettingsView()
                    .environmentObject(data)
                    .preferredColorScheme(appTheme.asColorScheme ?? colorScheme)
            }
        }
        .background(Color(.secondarySystemBackground))
        .task {
            data.retrieveUSSDCodes()
            await AirtimeToInsightMigrator.shared.migrate()
        }
        .navigationTitle("Dialer")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if allowBiometrics {
                    settingsImage
                        .onTapForBiometrics {
                            if $0 {
                                data.showSettingsView()
                            }
                        }
                } else {
                    Button(action: data.showSettingsView) { settingsImage }
                }
            }
            
            ToolbarItem(placement: .bottomBar) {
                
            }
        }
        .trackAppearance(.dashboard)
    }
}

private extension DashBoardView {
    private var settingsGradientIcon: some View {
        Image(systemName: "gear")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 30, height: 30)
            .foregroundStyle(
                LinearGradient(gradient: Gradient(colors: [.red, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing)
            )
    }
    @ViewBuilder
    var settingsImage: some View {
        if #available(iOS 17.0, *) {
            settingsGradientIcon
                .symbolEffect(.scale.down, isActive: data.presentedSheet == .settings)
        } else {
            settingsGradientIcon
        }
    }
}

@available(iOS 17.0, *)
struct QRCodeScannerTip: Tip {
    var title: Text {
        Text("Scan MoMo QR code to pay.")
    }

    var image: Image? {
        Image(systemName: "qrcode").resizable()
    }
}

#Preview {
    NavigationStack {
        DashBoardView(navPath: .constant([]))
            .environmentObject(MainViewModel())
            .environmentObject(UserStore())
    }
}
