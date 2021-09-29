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
    
    private let appearanceItems: [SettingsItem] = [
        .init(sysIcon: "trash", color: .red, title: "Change Icon",
              subtitle: "Choose the right fit for you.")
    ]
    
    @State private
    var showMailErrorAlert = false
    
    private let supportEmail = "abc.incs.001@gmail.com"
    private let twitterLink = "https://twitter.com/TheDialerApp"
    private let githubLink = "https://github.com/cedricbahirwe/dialer"
    
    @State var showMailView = false
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    
                    Section(header: sectionHeader("General settings")) {
                        VStack {
                            SettingsRow(.changeLanguage) {
                                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                            }
                            if dataStore.hasStoredPinCode {
                                SettingsRow(.deletePin, action: dataStore.removePin)
                            }
                        }
                        .padding(.bottom, 20)
                    }
                
                    Section(header: sectionHeader("Tips and Guides")){
                        VStack {
                            SettingsRow(.getStarted, action: {})
                        }
                        .padding(.bottom, 20)
                    }
                    
                    Section(header: sectionHeader("Reach Out")) {
                        VStack {
                            SettingsRow(.contactUs, action: openMail)
                                .alert("No Email Client Found",
                                       isPresented: $showMailErrorAlert) {
                                    Button("OK", role: .cancel) { }
                                    Button("Copy Support Email", action: copyEmail)
                                    Button("Open Twitter", action: openTwitter)
                                } message: {
                                    Text("We could not detect a default mail service on your device.\n\n You can reach us on Twitter, or send us an email to abc.incs.001@gmail.com as well.")
                                }
                            Link(destination: URL(string: twitterLink)!) {
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
                            Link(destination: URL(string: githubLink)!) {
                                SettingsRow(.review)
                            }
                        }
                        .padding(.bottom, 20)
                    }
                }
                .padding(.horizontal, 10)
                .foregroundColor(.primary.opacity(0.8))
            }
            .navigationTitle("Help & More")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showMailView) {
                MailView(recipientEmail: supportEmail,  bodyMessage: getEmailBody())
            }
            .safeAreaInset(edge: .bottom, content: {
                Text(" By using Dilaer, you accept our\n[Terms & Conditions](www.google.com) and [Privacy Policy](www.google.com).")
                    .font(.subheadline)
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
            body.append("\nDialer Version: \(appVersion)")
        }
        if let buildVersion = UIApplication.buildVersion {
            body.append("\nDialer Build: \(buildVersion)")
        }
        return body
    }
    private func copyEmail() {
        let pasteBoard = UIPasteboard.general
        pasteBoard.string = "https://twitter.com/TheDialerApp"
    }
    
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.title3.weight(.semibold))
            .padding(.vertical)
    }
    
    
    private func openTwitter() {
        
        guard let url = URL(string: twitterLink) else { return }
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

struct MailView: UIViewControllerRepresentable {
    let recipientEmail: String
    let bodyMessage: String
    
    func makeUIViewController(context: Context) -> UIViewController {
        let mail = MFMailComposeViewController()
        mail.navigationBar.prefersLargeTitles = false
        mail.mailComposeDelegate = context.coordinator
        mail.setToRecipients([recipientEmail])
        mail.setSubject("Dialer Question")
        
        mail.setMessageBody(bodyMessage, isHTML: false)
        return mail
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailView
        
        init(_ parent: MailView) {
            self.parent = parent
        }
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true)
        }
        
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(MainViewModel())
    }
}
extension SettingsView {
    
    struct SettingsRow: View {
        
        init(_ option: SettingsOption,
             action: @escaping () -> Void) {
            self.item = option.getItem()
            self.action = action
        }
        init(_ option: SettingsOption) {
            self.item = option.getItem()
            self.action = nil
        }
        
        let item: SettingsItem
        let action: (() -> Void)?
        
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
            HStack(spacing: 15) {
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
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 5)
        }
    }
}
