//
//  SettingsView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 02/09/2021.
//

import SwiftUI
import AuthenticationServices

struct SettingsView: View {
    @StateObject private var settingsStore = SettingsStore()
    @StateObject private var mailComposer = MailComposer()
    @EnvironmentObject var dataStore: MainViewModel

    @AppStorage(UserDefaultsKeys.allowBiometrics)
    private var allowBiometrics = false

    @AppStorage(UserDefaultsKeys.isDialerSplitsEnabled)
    private var allowDialerSplits = false

    @AppStorage(UserDefaultsKeys.appTheme)
    private var appTheme: DialerTheme = .system

    @State private var alertItem: AlertDialog?
    @State private var showUssdDeletionDialog = false
    @State private var showDonateSheet: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if settingsStore.isLoggedIn, let userInfo = settingsStore.userInfo {
                        UserProfilePreview(
                            info: userInfo,
                            onSignOut: settingsStore.signoutFromApple
                        )
                    } else {
                        SignInWithAppleButton(
                            onRequest: { request in
                                request.requestedScopes = [.fullName, .email]
                            },
                            onCompletion: settingsStore.handleAppleSignInCompletion
                        )
                        .frame(height: 45)

                        Text("Sign in with your Apple ID to sync your Dialer data (Merchants, Insights, and Preferences) across your Apple devices.")
                            .foregroundStyle(.secondary)
                            .font(.footnote)
                    }

                    SettingsRow(.supportUs, action: presentDonationSheet)

                } header: {
                    if settingsStore.isLoggedIn {
                        sectionHeader("Account")
                    }
                }

                Section {
                    HStack(spacing: 3) {
                        SettingsRow(.dialerSplits)
                        Toggle("Biometrics", isOn: $allowDialerSplits)
                            .toggleStyle(SwitchToggleStyle())
                            .labelsHidden()
                    }
                } header: {
                    sectionHeader("Preferences")
                }

                Section {
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
                        SettingsRow(item: .init(
                            sysIcon: {
                                if #available(iOS 17, *) {
                                    "circle.lefthalf.filled.inverse"
                                } else {
                                    "moon.circle.fill"
                                }
                            }(),
                            color: .green,
                            title: "Appearance",
                            subtitle: "Current: **\((appTheme).rawCapitalized)**"))
                    }

                    if !dataStore.ussdCodes.isEmpty {
                        SettingsRow(.deleteUSSDs,
                                    action: presentUSSDsRemovalSheet)
                    }
                } header: {
                    sectionHeader("General settings")
                }
                .confirmationDialog("Confirmation",
                                    isPresented: $showUssdDeletionDialog,
                                    titleVisibility: .visible,
                                    presenting: alertItem)
                { item in

                    Button("Delete",
                           role: .destructive,
                           action: item.action)

                    Button("Cancel",
                           role: .cancel) {
                        alertItem = nil
                    }
                } message: { item in
                    VStack {
                        Text(item.message)
                        Text(item.title ?? "")
                    }
                }

                Section {
                    SettingsRow(.contactUs, action: mailComposer.openMail)
                        .alert("No Email Client Found",
                               isPresented: $mailComposer.showMailErrorAlert) {
                            Button("OK", role: .cancel) { }
                            Button("Copy Support Email", action: mailComposer.copySupportEmail)
                            Button("Open Twitter", action: mailComposer.openTwitter)
                        } message: {
                            Text("We could not detect a default mail service on your device.\n\n You can reach us on Twitter, or send us an email to \(DialerlLinks.supportEmail) as well."
                            )
                        }
                    Link(destination: URL(string: DialerlLinks.dialerTwitter)!) {
                        SettingsRow(.tweetUs)
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

            }
            .foregroundStyle(.primary.opacity(0.8))
            .navigationTitle("Help & More")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: ReviewHandler.requestReview)
            .sheet(isPresented: $showDonateSheet) {
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
            .task {
                await settingsStore.checkAuthenticationState()
            }
            .trackAppearance(.settings)
        }
    }

}

private extension SettingsView {
    func presentDonationSheet() {
        showDonateSheet.toggle()
    }

    private func presentUSSDsRemovalSheet() {
        alertItem = .init(
            "Confirmation",
            message: "Do you really want to remove your saved USSD codes?\nThis action can not be undone.",
            action: dataStore.removeAllUSSDs
        )
        showUssdDeletionDialog.toggle()
    }

    private func sectionHeader(_ title: LocalizedStringKey) -> some View {
        Text(title)
            .font(.title3.weight(.semibold))
            .textCase(nil)
    }

    private func setAppTheme(_ newTheme: DialerTheme) {
        self.appTheme = newTheme
    }
}

#Preview {
    SettingsView()
        .environmentObject(MainViewModel())
}

