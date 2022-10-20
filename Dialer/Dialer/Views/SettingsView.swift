//
//  SettingsView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 02/09/2021.
//

import SwiftUI
import MessageUI

struct SettingsView: View {
    @EnvironmentObject var dataStore: MainViewModel
    
    @AppStorage(UserDefaults.Keys.allowBiometrics)
    private var allowBiometrics = false
    @State var showMailView = false
    @State var showMailErrorAlert = false
    @State var alertItem: AlertDialog?
    @State var showDialog = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    
                    Section(header: sectionHeader("General settings")) {
                        VStack {
                            SettingsRow(.changeLanguage, exists: false) {
                                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                            }

                            HStack(spacing: 3) {
                                SettingsRow(.biometrics, exists: false)
                                Toggle("Biometrics", isOn: $allowBiometrics)
                                    .toggleStyle(SwitchToggleStyle())
                                    .labelsHidden()
                            }

                            if dataStore.hasStoredPinCode {
                                SettingsRow(.deletePin,
                                            action: presentPinRemovalSheet)
                            }

                            if !dataStore.ussdCodes.isEmpty {
                                SettingsRow(.deleteUSSDs,
                                            action: presentUSSDsRemovalSheet)
                            }
                        }
                        .padding(.bottom, 20)
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

//                    Section(header: sectionHeader("Tips and Guides")){
//                        VStack {
//                            HStack(spacing: 0) {
//                                SettingsRow(.getStarted, exists: false)
//                            }
//                        }
//                        .padding(.bottom, 20)
//                    }
                    
                    Section(header: sectionHeader("Reach Out")) {
                        VStack {
                            SettingsRow(.contactUs, action: openMail)
                                .alert("No Email Client Found",
                                       isPresented: $showMailErrorAlert) {
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
                            
                            SettingsRow(.translationSuggestion, action: openMail)
                            
                        }
                        .padding(.bottom, 20)
                    }
                    Section(header: sectionHeader("Colophon")) {
                        
                        VStack {
                            NavigationLink(destination: AboutView()) {
                                SettingsRow(.about)
                            }
                            
                            SettingsRow(.review, action: ReviewHandler.requestReviewManually)
                        }
                        .padding(.bottom, 20)
                    }
                }
                .padding(.horizontal, 10)
                .foregroundColor(.primary.opacity(0.8))
            }
            .background(Color.primaryBackground)
            .navigationTitle("Help & More")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: ReviewHandler.requestReview)
            .sheet(isPresented: $showMailView) {
                MailView(recipientEmail: DialerlLinks.supportEmail,
                         subject: "Dial It Question",
                         bodyMessage: getEmailBody())
            }
            .safeAreaInset(edge: .bottom, content: {
                
                Text("By using Dial It, you accept our\n[Terms & Conditions](https://cedricbahirwe.github.io/html/privacy.html) and [Privacy Policy](https://cedricbahirwe.github.io/html/privacy.html).")
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
    
    
    private func getEmailBody() -> String {
        var body = "\n\n\n\n\n\n\n\n"
        
        let deviceName = UIDevice.current.localizedModel
        body.append(contentsOf: deviceName)
        
        let iosVersion = "iOS Version: \(UIDevice.current.systemVersion)"
        body.append(iosVersion)
        
        if let appVersion  = UIApplication.appVersion {
            body.append("\nDial It Version: \(appVersion)")
        }
        if let buildVersion = UIApplication.buildVersion {
            body.append("\nDial It Build: \(buildVersion)")
        }
        return body
    }

    private func copyEmail() {
        let pasteBoard = UIPasteboard.general
        pasteBoard.string = DialerlLinks.dialerTwitter
    }
    
    private func sectionHeader(_ title: LocalizedStringKey) -> some View {
        Text(title)
            .font(.title3.weight(.semibold))
            .padding(.vertical)
    }
    
    
    private func openTwitter() {
        
        guard let url = URL(string: DialerlLinks.dialerTwitter) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    private func openMail() {
        
        if MFMailComposeViewController.canSendMail() {
            showMailView.toggle()
        } else {
            showMailErrorAlert = true
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(MainViewModel())
        //            .preferredColorScheme(.dark)
    }
}
extension SettingsView {
    
    struct SettingsRow: View {
        
        init(_ option: SettingsOption,
             exists: Bool = true,
             action: @escaping () -> Void) {
            self.item = option.getSettingsItem()
            self.exists = exists
            self.action = action
        }
        init(_ option: SettingsOption, exists: Bool = true) {
            self.item = option.getSettingsItem()
            self.exists = exists
            self.action = nil
        }
        
        private let item: SettingsItem
        private let exists: Bool
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
                    .frame(width: 30, height:30)
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
                
                if exists {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 5)
        }
    }
}
