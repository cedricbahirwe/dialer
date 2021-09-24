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
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    
                    Section(header: sectionHeader("General settings")) {
                        VStack {
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
                            
                            SettingsRow(.translationSuggestion, action: {})
                        }
                        .padding(.bottom, 20)
                    }
                    Section(header: sectionHeader("Colophon")) {
                        
                        VStack {
                            NavigationLink(destination: AboutView()) {
                                SettingsRow(.about)
                            }
                            SettingsRow(.review, action: {})
                        }
                        .padding(.bottom, 20)
                    }
                }
                .padding(.horizontal, 10)
                .foregroundColor(.primary.opacity(0.8))
            }
            .navigationTitle("Help & More")
            .navigationBarTitleDisplayMode(.inline)
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
            print("I can send to \(supportEmail)")
//            let mail = MFMailComposeViewController()
////            mail.mailComposeDelegate = self
//            mail.setToRecipients([recipientEmail])
//            mail.setSubject(subject)
//            mail.setMessageBody(body, isHTML: false)
//
//            present(mail, animated: true)
        } else {
            showMailErrorAlert = true
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
