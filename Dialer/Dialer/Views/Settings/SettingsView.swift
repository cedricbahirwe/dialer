//
//  SettingsView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 02/09/2021.
//

import SwiftUI

struct SettingsView: View {
//    @StateObject private var settingsStore = SettingsStore()
    @StateObject private var mailComposer = MailComposer()
    @EnvironmentObject private var dataStore: MainViewModel
    @EnvironmentObject private var userStore: UserStore
    @EnvironmentObject private var merchantStore: UserMerchantStore
    @EnvironmentObject private var insightsStore: DialerInsightStore

    @AppStorage(UserDefaultsKeys.allowBiometrics)
    private var allowBiometrics = false

    @AppStorage(UserDefaultsKeys.isDialerSplitsEnabled)
    private var allowDialerSplits = false

    @AppStorage(UserDefaultsKeys.appTheme)
    private var appTheme: DialerTheme = .system

    @State private var alertItem: AlertDialog?
    @State private var showConfirmationAlert = false
    @State private var showTipSheet = false
    @State private var isDeleting = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 3) {
                        SettingsRow(.dialerSplits)
                        Toggle("Dialer Splits", isOn: $allowDialerSplits)
                            .toggleStyle(SwitchToggleStyle())
                            .labelsHidden()
                    }

                    HStack(spacing: 3) {
                        SettingsRow(.biometrics)
                        Toggle("Biometrics", isOn: $allowBiometrics)
                            .toggleStyle(SwitchToggleStyle())
                            .labelsHidden()
                    }

                    Menu {
                        ForEach(DialerTheme.allCases, id: \.self) { theme in
                            Button(theme.rawCapitalized, systemImage: theme.getIconSystemName()) {
                                setAppTheme(theme)
                            }
                        }
                    } label: {
                        SettingsRow(.appearance(currentTheme: appTheme))
                    }
                } header: {
                    sectionHeader("Preferences")
                }

                Section {
                    SettingsRow(.supportUs, action: goToTipping)

                    SettingsRow(.contactUs, action: mailComposer.openMail)
                        .alert("No Email Client Found",
                               isPresented: $mailComposer.showMailErrorAlert) {
                            Button("OK", role: .cancel) { }
                            Button("Copy Support Email", action: mailComposer.copySupportEmail)
                            Button("Open X", action: mailComposer.openX)
                        } message: {
                            Text("We could not detect a default mail service on your device.\n\n You can reach us on X, or send us an email to \(DialerlLinks.supportEmail) as well."
                            )
                        }
                    Link(destination: URL(string: DialerlLinks.dialerX)!) {
                        SettingsRow(.socialX)
                    }
                } header: {
                    sectionHeader("Reach out")
                }

                Section {
                    NavigationLink(destination: AboutView()) {
                        SettingsRow(.about)
                    }

                    SettingsRow(.review, action: ReviewHandler.requestReviewManually)

                } header: {
                    sectionHeader("Colophon")
                }

                Section {
                    if !dataStore.ussdCodes.isEmpty {
                        SettingsRow(
                            .deleteUSSDs,
                            action: presentUSSDsRemovalSheet
                        )
                    }

                    HStack {
                        SettingsRow(
                            .deleteAccount,
                            action: presentAccountDeletion
                        )
                        if isDeleting {
                            ProgressView()
                                .progressViewStyle(.circular)
                        }
                    }
                } header: {
                    sectionHeader("Danger Zone")
                }
                .confirmationDialog(
                    "Confirmation",
                    isPresented: $showConfirmationAlert,
                    titleVisibility: .visible,
                    presenting: alertItem
                ) { item in
                    Button(
                        "Delete",
                        role: .destructive,
                        action: item.action
                    )
                    Button(
                        "Cancel",
                        role: .cancel
                    ) {
                        alertItem = nil
                    }
                } message: { item in
                    VStack {
                        Text(item.message)
                        Text(item.title ?? "")
                    }
                }
            }
            .foregroundStyle(.primary.opacity(0.8))
            .navigationTitle("Settings           ")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: ReviewHandler.requestReview)
            .sheet(isPresented: $showTipSheet) {
                DonationView()
            }
            .sheet(isPresented: $mailComposer.showMailView) {
                mailComposer.makeMailView()
            }
            .safeAreaInset(edge: .bottom) {
                Text("By using Dialer, you accept our\n[Terms & Conditions](https://cedricbahirwe.github.io/html/privacy.html) and [Privacy Policy](https://cedricbahirwe.github.io/html/privacy.html).")
                    .font(.subheadline.bold())
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.thinMaterial)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dataStore.dismissSettingsView()
                    }.font(.body.bold())
                }
            }
            .trackAppearance(.settings)
        }
    }
}

private extension SettingsView {
    func goToTipping() {
        showTipSheet.toggle()
    }

    private func presentUSSDsRemovalSheet() {
        alertItem = .init(
            "Confirmation",
            message: "Do you really want to remove your saved USSD codes?\nThis action can not be undone.",
            action: dataStore.removeAllUSSDs
        )
        showConfirmationAlert.toggle()
    }

    private func presentAccountDeletion() {
        alertItem = .init(
            "Confirmation",
            message: "All your information will be permenantly deleted (Merchant Codes, USSD codes, etc.).\nThis action can not be undone.",
            action: deleteAccount
        )
        showConfirmationAlert.toggle()
    }

    private func sectionHeader(_ title: LocalizedStringKey) -> some View {
        Text(title)
            .font(.title3.weight(.semibold))
            .textCase(nil)
    }

    private func setAppTheme(_ newTheme: DialerTheme) {
        self.appTheme = newTheme
    }

    private func deleteAccount() {
        Task {
            isDeleting = true
            // Clear USSDs
            dataStore.removeAllUSSDs()
            // Clear Merchant codes
            await merchantStore.deleteAllUserMerchants()
            // Clear Transactions
            await insightsStore.deleteAllUserInsights()

            // Remove user
            await userStore.deleteUser()

            // Clear Userdefaults Device Data
            DialerStorage.shared.clearDevice()

            // Clear Local Preferences
            allowDialerSplits = false
            allowBiometrics = false

            isDeleting = false
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(MainViewModel())
        .environmentObject(UserStore())
        .environmentObject(UserMerchantStore())
        .environmentObject(DialerInsightStore())
//        .preferredColorScheme(.dark)
}
