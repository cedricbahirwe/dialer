//
//  UserDetailsCreationView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 02/08/2024.
//  Copyright © 2024 Cédric Bahirwe. All rights reserved.
//

import SwiftUI

struct UserDetailsCreationView: View {
    @AppStorage(UserDefaultsKeys.showUsernameSheet)
    private var showUsernameSheet = true

    @EnvironmentObject private var userStore: UserStore
    @StateObject private var mailComposer = MailComposer()

    @State private var username = ""
    @State private var enteredRecoveryCode = ""
    @State private var showRestoreAlert = false
    @State private var isValidating = false
    @State private var usernameAvailable: Bool = false
    @State private var recoveryFileURL: URL?

    @State private var isRestoringUser = false
    @Environment(\.colorScheme) private var colorScheme

    private var isUsernameValid: Bool {
        return username.count >= 3 &&
        username.count <= 30
    }

    private var isValidRecoveryCode: Bool {
        !enteredRecoveryCode.withoutSpacing().isEmpty
    }

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack {
            Spacer()
            Group {
                userStore.recoveryCode == nil
                ? Text("I am **Dialer**")
                : Text(username).fontWeight(.bold)
            }
            .font(.system(.title, design: .rounded))
            .padding(.bottom, 24)

            if userStore.recoveryCode == nil {
                Text("How should I call you?")
                    .fontWeight(.heavy)
            }

            VStack(spacing: 20) {

                if let recoveryCode = userStore.recoveryCode {
                    recoveryCodeView(recoveryCode)
                } else {
                    usernameFieldView
                    usernameActionsView
                }
            }
            Spacer()
            Spacer()
        }
        .padding(.horizontal)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .font(.system(.body, design: .rounded))
//        .fontDesign(.rounded)
        .safeAreaInset(edge: .top) {
            Text(userStore.recoveryCode == nil ? "Hello 👋🏽" : "Glad to have you")
                .font(.system(.title2, design: .rounded, weight: .semibold))
                .frame(maxWidth: .infinity, alignment: .center)
                .overlay(alignment: .trailing) {
                    if userStore.recoveryCode == nil {
                        HStack {
                            Button("Help", action: mailComposer.openMail)
                            .alert("No Email Client Found",
                                   isPresented: $mailComposer.showMailErrorAlert) {
                                Button("OK", role: .cancel) { }
                                Button("Copy Support Email", action: mailComposer.copySupportEmail)
                                Button("Open Twitter", action: mailComposer.openTwitter)
                            } message: {
                                Text("We could not detect a default mail service on your device.\n\n You can reach us on Twitter, or send us an email to \(DialerlLinks.supportEmail) as well."
                                )
                            }
                            .foregroundStyle(Color.accentColor)
                            .bold()
                            .disabled(userStore.recoveryCode != nil)


                            Spacer()
                            Button("Restore") {
                                showRestoreAlert.toggle()
                            }
                            .foregroundStyle(Color.accentColor)
                            .disabled(userStore.recoveryCode != nil)
                            .bold()
                            .alert(
                                "Enter your recovery code",
                                isPresented: $showRestoreAlert
                            ) {
                                TextField(
                                    "Recovery code...",
                                    text: $enteredRecoveryCode)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .foregroundStyle(Color.accentColor)

                                Button("Cancel") {
                                    enteredRecoveryCode = ""
                                }
                                Button("Continue", action: restoreUser)
                                    .disabled(!isValidRecoveryCode)
                            } message: {
                                Text("This code will restore your information on the app.")
                            }
                        }

                    }
                }
                .padding()
        }
        .sheet(isPresented: $mailComposer.showMailView) {
            mailComposer.makeMailView()
        }
        .overlay {
            if isRestoringUser {
                ZStack {
                    Color.black.ignoresSafeArea()
                    ProgressView("Wait a moment...")
                        .font(.system(.title2, design: .rounded, weight: .semibold))
                        .tint(.white)
                }
            }
        }
        .foregroundStyle(.white)
        .background(.matteBlack, ignoresSafeAreaEdges: .all)
        .onAppear() {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.05) {
                isFocused = true
            }
        }
        .preferredColorScheme(.dark)
        .trackAppearance(.newMerchant)
    }

    private func validateUsername(_ username: String) {
        let cleanUsername = username.filter({ !$0.isWhitespace })
        if username != cleanUsername {
            self.username = cleanUsername
            return
        }

        withAnimation {
            self.usernameAvailable = userStore.isUsernameAvailable(username)
        }
    }

    private func saveUser() {
        hideKeyboard()
        Task {
            isValidating = true
            let success = await userStore.saveUser(username)
            isValidating = false
            if success {
                makeRecoveryCodeFile()
            } else {
                showUsernameSheet = false
            }
        }
    }

    private func restoreUser() {
        hideKeyboard()
        Task {
            withAnimation {
                isRestoringUser = true
            }
            let success = await userStore.restoreUser(enteredRecoveryCode)

            enteredRecoveryCode = ""
            if success {
                showUsernameSheet = false
            }
            withAnimation {
                isRestoringUser = false
            }
        }
    }

    func makeRecoveryCodeFile() {
        guard let recoveryCode = userStore.recoveryCode else { return }
        let tempDirectoryURL = FileManager.default.temporaryDirectory
        let fileURL = tempDirectoryURL.appendingPathComponent("DialerRecovery.txt")

        do {
            try recoveryCode.write(to: fileURL, atomically: true, encoding: .utf8)
            self.recoveryFileURL = fileURL
        } catch {
            Tracker.shared.logError(error: error)
        }
    }

    @ViewBuilder
    func makeRecoveryCodeLabel(_ recoveryCode: String) -> some View {
        Label(recoveryCode, systemImage: "square.and.arrow.up")
            .font(.system(.body, design: .monospaced, weight: .medium))
            .lineLimit(1)
            .truncationMode(.middle)
            .padding(6)
            .background(.white.opacity(0.95), in: .rect(cornerRadius: 8))
    }

    private var usernameFieldView: some View {
        TextField("", text: $username)
            .font(.title.bold())
            .multilineTextAlignment(.center)
            .focused($isFocused)
            .textContentType(.nickname)
            .textInputAutocapitalization(.never)
            .onChange(of: username, perform: validateUsername)
            .overlay {
                if username.isEmpty {
                    Text("username")
                        .foregroundStyle(.secondary)
                        .font(.title.bold())
                        .allowsHitTesting(false)
                }
            }
    }
    private var usernameActionsView: some View {
        VStack(spacing: 24.0) {
            if isUsernameValid && !usernameAvailable {
                Text("This username is not available")
                    .foregroundStyle(Color.accentColor.gradient)
            }

            Button(action: saveUser) {
                Group {
                    if isValidating {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(Color.accentColor)
                    } else {
                        Label("next", systemImage: "arrow.right")
                            .fontWeight(.semibold)
                    }
                }
                .padding(10)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .disabled(isValidating || !isUsernameValid || !usernameAvailable)
        }
    }

    @ViewBuilder
    private func recoveryCodeView(_ recoveryCode: String) -> some View {
        VStack(spacing: 24.0) {
            Text("Below is your recovery code:")
                .fontWeight(.heavy)

            HStack(spacing: 12) {

                if let recoveryFileURL {
                    ShareLink(item: recoveryFileURL) {
                        makeRecoveryCodeLabel(recoveryCode)
                    }
                } else {
                    makeRecoveryCodeLabel(recoveryCode)
                }

                Button("Copy") {
                    UIPasteboard.general.string = recoveryCode
                }
            }
            .frame(maxWidth: 300)
            .foregroundStyle(Color.accentColor)

            Button(action: {
                showUsernameSheet = false
            }) {
                Text("Finish")
                    .fontWeight(.semibold)
                    .padding(6)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
        }
    }
}

#Preview {
    UserDetailsCreationView()
        .environmentObject(UserStore())
}
