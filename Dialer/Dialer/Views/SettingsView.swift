//
//  SettingsView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 02/09/2021.
//

import SwiftUI
import MessageUI

struct SettingsView: View {
    @EnvironmentObject
    private var dataStore: MainViewModel
    
    @AppStorage(UserDefaults.Keys.allowBiometrics)
    private var allowBiometrics = false
    @State private
    var showMailErrorAlert = false
    
    @State var showMailView = false
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
                                SettingsRow(.deletePin, perform: dataStore.removePin)
                            }

                            if !dataStore.ussdCodes.isEmpty {
                                SettingsRow(.deleteUSSDs, perform: dataStore.removeAllUSSDs)
                            }
                        }
                        .padding(.bottom, 20)
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
                            Link(destination: URL(string: DialerlLinks.patreaonSupport)!) {
                                SettingsRow(.patreonSupport)
                            }

                            SettingsRow(.contactUs, perform: openMail)
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
                            
                            SettingsRow(.translationSuggestion, perform: openMail)
                            
                        }
                        .padding(.bottom, 20)
                    }
                    Section(header: sectionHeader("Colophon")) {
                        
                        VStack {
                            NavigationLink(destination: AboutView()) {
                                SettingsRow(.about)
                            }
                            
                            SettingsRow(.review, perform: ReviewHandler.requestReviewManually)
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
             perform action: @escaping () -> Void) {
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
                Button(action: action, label: {
                    contenView
                })
            } else {
                contenView
            }
        }
        
        var contenView: some View {
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
//                .lineLimit(1)
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
