//
//  MailService.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 16/10/2023.
//

import Foundation
import MessageUI

class MailService: ObservableObject {
    @Published var showMailView = false
    @Published var showMailErrorAlert = false
    
    func openMail() {
        if MFMailComposeViewController.canSendMail() {
            showMailView.toggle()
        } else {
            showMailErrorAlert = true
        }
    }

    func openX() {
        guard let url = URL(string: DialerlLinks.dialerX) else { return }
        UIApplication.shared.open(url)
    }

    func copySupportEmail() {
        let pasteBoard = UIPasteboard.general
        pasteBoard.string = DialerlLinks.supportEmail
    }

    @MainActor func makeMailView() -> MailView {
        MailView(recipientEmail: DialerlLinks.supportEmail,
                 subject: "Dialer Support Question",
                 bodyMessage: getEmailBody())
    }
    
    private func getEmailBody() -> String {
        var body = "\n\n\n\n\n\n\n\n"
        
        let deviceName = UIDevice.current.localizedModel
        body.append(contentsOf: deviceName)
        
        let iosVersion = "\niOS Version: \(UIDevice.current.systemVersion)"
        body.append(iosVersion)
        
        if let appVersion  = UIApplication.appVersion {
            body.append("\nDialer Version: \(appVersion)")
        }
        if let buildVersion = UIApplication.buildVersion {
            body.append("\nDialer Build: \(buildVersion)")
        }
        return body
    }
}
