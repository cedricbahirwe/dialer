//
//  SettingsView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 02/09/2021.
//

import SwiftUI
import AuthenticationServices

struct SettingsView: View {
    @State private var isLoggedIn = false
    @AppStorage(UserDefaultsKeys.allowBiometrics)
    private var allowBiometrics = false

    @AppStorage(UserDefaultsKeys.appTheme)
    private var appTheme: DialerTheme = .system

    @EnvironmentObject var dataStore: MainViewModel

    @StateObject private var mailComposer = MailComposer()

    @State private var alertItem: AlertDialog?
    @State private var showDialog = false
    @State private var userInfo: AppleInfo? = DialerStorage.shared.getAppleInfo()

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if isLoggedIn, let userInfo {
                        UserProfilePreview(
                            info: userInfo,
                            onSignOut: signoutFromApple
                        )
                    } else {
                        signInWithAppleView
                            .frame(height: 45)

                        Text("Sign in with your Apple ID to sync your Dialer data (Merchants, Insights, and Preferences) across your Apple devices.")
                            .foregroundStyle(.secondary)
                            .font(.footnote)
                    }
                } header: {
                    if isLoggedIn {
                        sectionHeader("Account")
                    }
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
                            sysIcon: "circle.lefthalf.filled.inverse",
                            color: .green,
                            title: "Change Mode",
                            subtitle: "Current Mode: **\((appTheme).rawCapitalized)**"))
                    }

                    if !dataStore.ussdCodes.isEmpty {
                        SettingsRow(.deleteUSSDs,
                                    action: presentUSSDsRemovalSheet)
                    }
                } header: {
                    sectionHeader("General settings")
                }
                .confirmationDialog("Confirmation",
                                    isPresented: $showDialog,
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
                    sectionHeader("Reach Out")
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
                await checkAuthenticationState()
            }
            .trackAppearance(.settings)
        }
    }

    private var signInWithAppleView: some View {
        SignInWithAppleButton(
            onRequest: { request in
                request.requestedScopes = [.fullName, .email]
            },
            onCompletion: { result in
                switch result {
                case .success(let authResults):
                    if let appleIDCredential  = authResults.credential as? ASAuthorizationAppleIDCredential {
                        // Only Save info it does not exist
                        let userIdentifier = appleIDCredential.user

                        if DialerStorage.shared.getAppleInfo() == nil {
                            let fullName = appleIDCredential.fullName
                            let email = appleIDCredential.email

                            let info = AppleInfo(
                                userId: userIdentifier,
                                fullname: fullName,
                                email: email
                            )

                            self.userInfo = info

                            do {
                                try DialerStorage.shared.saveAppleInfo(info)
                            } catch {
                                Tracker.shared.logError(error: error)
                            }
                        }

                        // Store the `userIdentifier` in the keychain.
                        self.saveUserInKeychain(userIdentifier)

                        self.isLoggedIn = true
                    }
                case .failure(let error):
                    print("Auth Failed: ", error)
                }
            }
        )
    }

    private func saveUserInKeychain(_ userIdentifier: String) {
        do {
            try KeychainItem(service: Bundle.main.bundleIdentifier!, account: "userIdentifier").saveItem(userIdentifier)
        } catch {
            print("Unable to save userIdentifier to keychain.")
        }
    }

    private func checkAuthenticationState() async {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        do {
            let credentialState = try await appleIDProvider.credentialState(forUserID: KeychainItem.currentUserIdentifier)
            switch credentialState {
            case .authorized:
                isLoggedIn = true
            case .revoked, .notFound:
                // The Apple ID credential is either revoked or was not found.
                signoutFromApple()
            default:
                break
            }
        } catch {
            signoutFromApple()
        }
    }

    private func signoutFromApple() {
        KeychainItem.deleteUserIdentifierFromKeychain()
//        DialerStorage.shared.removeAppleSignInInfo()
        isLoggedIn = false
    }

    private func presentUSSDsRemovalSheet() {
        alertItem = .init("Confirmation",
                          message: "Do you really want to remove your saved USSD codes?\nThis action can not be undone.",
                          action: dataStore.removeAllUSSDs)
        showDialog.toggle()
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

extension SettingsView {

    struct SettingsRow: View {
        init(item: SettingsItem, action: @escaping () -> Void) {
            self.item = item
            self.action = action
        }

        init(item: SettingsItem) {
            self.item = item
            self.action = nil
        }

        init(_ option: SettingsOption, action: @escaping () -> Void) {
            self.init(item: option.getSettingsItem(), action: action)
        }

        init(_ option: SettingsOption) {
            self.item = option.getSettingsItem()
            self.action = nil
        }

        private let item: SettingsItem
        private let action: (() -> Void)?

        var body: some View {
            if let action = action {
                Button(action: action) { contentView }
            } else {
                contentView
            }
        }

        @State private var animateSymbol = false

        private var iconImageView: some View {
            item.icon
                .resizable()
                .scaledToFit()
                .padding(6)
                .frame(width: 28, height: 28)
                .background(item.color)
                .cornerRadius(6)
                .foregroundStyle(.white)
        }

        var contentView: some View {
            HStack(spacing: 0) {
                if #available(iOS 17.0, *) {
                    iconImageView
                        .symbolEffect(.bounce.down, value: animateSymbol)
                } else {
                    iconImageView
                }

                VStack(alignment: .leading) {
                    Text(item.title)
                        .font(.system(.callout, design: .rounded))
                    Text(item.subtitle)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.secondary)

                }
                .multilineTextAlignment(.leading)
                .minimumScaleFactor(0.8)
                .padding(.leading, 15)

                Spacer(minLength: 1)
            }
            .onAppear() {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                    animateSymbol = true
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(MainViewModel())
}

struct AppleInfo: Codable {
    let userId: String
    let fullname: PersonNameComponents?
    let email: String?
}
struct UserProfilePreview: View {
    let info: AppleInfo
    var onSignOut: () -> Void
    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 55)
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.red, Color.blue]),
                        startPoint: .topLeading,
                        endPoint: .trailing
                    )
                )
            
            VStack(alignment: .leading) {
                Text(info.fullname?.formatted() ?? "Unknown")
                Text(info.email ?? "-")
                    .font(.caption)
                    .foregroundStyle(.blue)
            }
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)

            Button("Sign Out", action: onSignOut)
                .font(.callout)
                .foregroundStyle(.red)
        }
    }
}
