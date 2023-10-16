//
//  MailComposer.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 16/10/2023.
//

import Foundation
import MessageUI

class MailComposer: ObservableObject {
    @Published var showMailView = false
    @Published var showMailErrorAlert = false
    
    func openMail() {
        if MFMailComposeViewController.canSendMail() {
            showMailView.toggle()
        } else {
            showMailErrorAlert = true
        }
    }
    
    @MainActor func makeMailView() -> MailView {
        MailView(recipientEmail: DialerlLinks.supportEmail,
                 subject: "Dialer Question",
                 bodyMessage: getEmailBody())
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
}
