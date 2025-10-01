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
    
    @EnvironmentObject private var dialerService: DialerService
    @EnvironmentObject private var insightsStore: DialerInsightStore

    @AppStorage(UserDefaultsKeys.shouldShowWelcome)
    private var shouldShowWelcome: Bool = true

    @State private var showWelcomeView: Bool = false
    @State private var airtimeTransaction = AirtimeTransaction()

    @AppStorage(UserDefaultsKeys.appTheme)
    private var appTheme: DialerTheme = .system

    @AppStorage(UserDefaultsKeys.showUsernameSheet)
    private var showUsernameSheet = false

    @AppStorage(UserDefaultsKeys.allowBiometrics)
    private var allowBiometrics = false

    @AppStorage(UserDefaultsKeys.didTransferMoneyCount)
    private var didTransferMoneyCount = 0

    @State private var showPurchaseSheet = false
    @State private var showWrappedSheet = false

    @Environment(\.colorScheme) private var colorScheme

    @available(iOS 17.0, *)
    var donationTip: DonationTip { DonationTip() }

    @State private var presentedSheet: DialerSheet?

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
                if shouldShowWelcome {
                    showWelcomeView = true
                }
            },
            content: {
                UserDetailsCreationView(showUsernameSheet: $showUsernameSheet)
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
            dialerService.retrieveUSSDCodes()
            if #available(iOS 17.0, *) {
                do {
//                     try Tips.resetDatastore()
                    try Tips.configure([
                        .displayFrequency(.weekly),
                        .datastoreLocation(.applicationDefault)
                    ])

                    if didTransferMoneyCount >= 3 {
                        DonationTip.isShown = true
                        didTransferMoneyCount = 0
                    } else {
                        DonationTip.isShown = false
                    }
                }
                catch {
                    Log.debug("Error initializing TipKit \(error.localizedDescription)")
                }
            }
        }
        .sheet(isPresented: $showPurchaseSheet) {
            if #available(iOS 16.4, *) {
                airtimePurchaseView
                    .presentationCornerRadius(20)
            } else {
                airtimePurchaseView
            }
        }
        .fullScreenCover(isPresented: $showWelcomeView) {
            WhatsNewView()
        }
        .sheet(item: $presentedSheet) { sheet in
            switch sheet {
            case .settings:
                SettingsView()
                    .environmentObject(dialerService)
                    .preferredColorScheme(appTheme.asColorScheme ?? colorScheme)
            case .tipping:
                TippingView()
            }
        }
        .background(Color(.secondarySystemBackground))
        .navigationTitle("Dialer")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if #available(iOS 17.0, *) {
                    settingsToolbarButton
                        .popoverTip(donationTip) { action in
                            if action.id == "donate" {
                                goToTipping()
                            }
                        }
                } else {
                    settingsToolbarButton
                }
            }
        }
        .trackAppearance(.dashboard)
    }
}

private extension DashBoardView {
    var airtimePurchaseView: some View {
        AirtimePurchaseSheet(
            isPresented: $showPurchaseSheet,
            transaction: $airtimeTransaction,
            onConfirm: {
                Task {
                    await dialerService.buyAirtime(airtimeTransaction)
                }
            }
        )
        .presentationDetents([.height(400)])
    }

    var settingsToolbarButton: some View {
        Group {
            if allowBiometrics {
                settingsImage
                .onTapForBiometrics {
                    if $0 {
                        showSettingsView()
                    }
                }

            } else {
                Button(action: showSettingsView) {
                    settingsImage
                }
            }
        }
    }

    @ViewBuilder
    var settingsImage: some View {
        if #available(iOS 17.0, *) {
            settingsGradientIcon
                .symbolEffect(.scale.down, isActive: presentedSheet == .settings)
        } else {
            settingsGradientIcon
        }
    }

    var settingsGradientIcon: some View {
        Image(systemName: "gear")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 30, height: 30)
            .foregroundStyle(
                LinearGradient(gradient: Gradient(colors: [.red, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing)
            )
    }
}

extension DashBoardView {
    enum DialerSheet: Int, Identifiable {
        var id: Int { rawValue }
        case settings
        case tipping
    }

    @MainActor func showSettingsView() {
        Tracker.shared.logEvent(.settingsOpened)
        presentedSheet = .settings
    }

    @MainActor func goToTipping() {
        Tracker.shared.logEvent(.tippingOpened)
        presentedSheet = .tipping
    }

    @MainActor func dismissSettingsView() {
        presentedSheet = nil
    }
}

#Preview {
    NavigationStack {
        DashBoardView(navPath: .constant([]))
            .environmentObject(DialerService())
            .environmentObject(UserStore())
    }
}
