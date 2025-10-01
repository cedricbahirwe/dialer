//
//  UserDetailsCreationView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 02/08/2024.
//  Copyright © 2024 Cédric Bahirwe. All rights reserved.
//

import SwiftUI

struct UserDetailsCreationView: View {
    @Binding var showUsernameSheet: Bool

    @EnvironmentObject private var userStore: UserStore
    @StateObject private var mailComposer = MailService()

    @State private var username = ""
    @State private var isValidating = false
    @State private var usernameAvailable: Bool = false

    private var isUsernameValid: Bool {
        return username.count >= 3 &&
        username.count <= 30
    }

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack {
            Spacer()
            HStack(spacing: 5) {
                Text(" I am")
                Text("Dialer")
                    .foregroundStyle(Color.mainRed)
                    .bold()
            }
            .font(.system(.title, design: .rounded))
            .padding(.bottom, 24)

            Text("How should I call you?")
                .fontWeight(.heavy)

            VStack(spacing: 20) {
                usernameFieldView
                usernameActionsView
            }
            Spacer()
            Spacer()

            Button("Help", action: mailComposer.openMail)
            .alert("No Email Client Found",
                   isPresented: $mailComposer.showMailErrorAlert) {
                Button("OK", role: .cancel) { }
                Button("Copy Support Email", action: mailComposer.copySupportEmail)
                Button("Open X", action: mailComposer.openX)
            } message: {
                Text("We could not detect a default mail service on your device.\n\n You can reach us on X, or send us an email to \(DialerlLinks.supportEmail) as well."
                )
            }
            .foregroundStyle(Color.accentColor)
            .bold()
            .padding()
        }
        .padding(.horizontal)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .font(.system(.body, design: .rounded))
        .safeAreaInset(edge: .top) {
            Text("Welcome on Dialer")
                .font(.system(.title2, design: .rounded, weight: .semibold))
                .frame(maxWidth: .infinity, alignment: .center)
                .overlay(alignment: .trailing) {
                    HStack {
                        Button("Close") {
                            showUsernameSheet = false
                        }
                        .bold()
                        .foregroundStyle(Color.red)

                        Spacer()
                        //                            Button("Restore") {
                        //                                showRestoreAlert.toggle()
                        //                            }
                        //                            .foregroundStyle(Color.accentColor)
                        //                            .disabled(userStore.recoveryCode != nil)
                        //                            .bold()
                    }
                }
                .padding()
        }
        .sheet(isPresented: $mailComposer.showMailView) {
            mailComposer.makeMailView()
        }
        .foregroundStyle(.white)
        .background(.matteBlack, ignoresSafeAreaEdges: .all)
        .onAppear() {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.05) {
                isFocused = true
            }
        }
        .preferredColorScheme(.dark)
        .trackAppearance(.newUsername)
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
            _ = await userStore.saveUser(username)
            isValidating = false
            showUsernameSheet = false
        }
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
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var showUsernameSheet: Bool = false

    return UserDetailsCreationView(showUsernameSheet: $showUsernameSheet)
        .environmentObject(UserStore())
}
