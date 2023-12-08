//
//  SettingsView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 02/09/2021.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage(UserDefaultsKeys.allowBiometrics)
    private var allowBiometrics = false
    
    @EnvironmentObject var dataStore: MainViewModel
    
    @StateObject private var mailComposer = MailComposer()
    
    @State var alertItem: AlertDialog?
    @State var showDialog = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack(spacing: 3) {
                        SettingsRow(.biometrics)
                        Toggle("Biometrics", isOn: $allowBiometrics)
                            .toggleStyle(SwitchToggleStyle())
                            .labelsHidden()
                    }
                    
                    if dataStore.hasStoredCodePin() {
                        SettingsRow(.deletePin,
                                    action: presentPinRemovalSheet)
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
                                    presenting: alertItem) { item in
                    
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
                        Text(item.title ?? "asfa")
                    }
                }
                
                Section {
                    SettingsRow(.contactUs, action: mailComposer.openMail)
                        .alert("No Email Client Found",
                               isPresented: $mailComposer.showMailErrorAlert) {
                            Button("OK", role: .cancel) { }
                            Button("Copy Support Email", action: copyEmail)
                            Button("Open Twitter", action: openTwitter)
                        } message: {
                            Text(String(format:
                                            NSLocalizedString("We could not detect a default mail service on your device.\n\n You can reach us on Twitter, or send us an email to supportEmail as well.", comment: ""),
                                        DialerlLinks.supportEmail
                                       )
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
            
            .foregroundColor(.primary.opacity(0.8))
            .navigationTitle("Help & More")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: ReviewHandler.requestReview)
            .sheet(isPresented: $mailComposer.showMailView) {
                mailComposer.makeMailView()
            }
            .safeAreaInset(edge: .bottom, content: {
                
                Text("By using Dialer, you accept our\n[Terms & Conditions](https://cedricbahirwe.github.io/html/privacy.html) and [Privacy Policy](https://cedricbahirwe.github.io/html/privacy.html).")
                    .font(.subheadline.bold())
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.thinMaterial)
            })
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dataStore.dismissSettingsView()
                    }.font(.body.bold())
                }
            }
            .trackAppearance(.settings)
        }
    }
    
    private func presentPinRemovalSheet() {
        alertItem = .init("Confirmation",
                          message: "Do you really want to remove your pin?.\nYou'll need to re-enter it manually later.",
                          action: dataStore.removePin)
        showDialog.toggle()
    }
    
    private func presentUSSDsRemovalSheet() {
        alertItem = .init("Confirmation",
                          message: "Do you really want to remove your saved USSD codes?\nThis action can not be undone.",
                          action: dataStore.removeAllUSSDs)
        showDialog.toggle()
    }
    
    private func copyEmail() {
        let pasteBoard = UIPasteboard.general
        pasteBoard.string = DialerlLinks.dialerTwitter
    }
    
    private func sectionHeader(_ title: LocalizedStringKey) -> some View {
        Text(title)
            .font(.title3.weight(.semibold))
            .textCase(nil)
    }
    
    
    private func openTwitter() {
        
        guard let url = URL(string: DialerlLinks.dialerTwitter) else { return }
        UIApplication.shared.open(url)
    }
}

extension SettingsView {
    
    struct SettingsRow: View {
        
        init(_ option: SettingsOption,
             action: @escaping () -> Void) {
            self.item = option.getSettingsItem()
            self.action = action
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
        
        var contentView: some View {
            HStack(spacing: 0) {
                item.icon
                    .resizable()
                    .scaledToFit()
                    .padding(6)
                    .frame(width: 28, height: 28)
                    .background(item.color)
                    .cornerRadius(6)
                    .foregroundColor(.white)
                
                VStack(alignment: .leading) {
                    Text(item.title)
                        .font(.system(.callout, design: .rounded))
                    Text(item.subtitle)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.secondary)
                    
                }
                .multilineTextAlignment(.leading)
                .minimumScaleFactor(0.8)
                .padding(.leading, 15)
                
                Spacer(minLength: 1)
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(MainViewModel())
    }
}
