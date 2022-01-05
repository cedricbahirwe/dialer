//
//  MailView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 04/01/2022.
//

import SwiftUI
import MessageUI

struct MailView: UIViewControllerRepresentable {
    let recipientEmail: String
    let subject: String
    let bodyMessage: String
    
    func makeUIViewController(context: Context) -> UIViewController {
        let mailComposer = MFMailComposeViewController()
        mailComposer.navigationBar.prefersLargeTitles = false
        mailComposer.mailComposeDelegate = context.coordinator
        
        mailComposer.setToRecipients([recipientEmail])
        mailComposer.setSubject(subject)
        mailComposer.setMessageBody(bodyMessage, isHTML: false)
        
        return mailComposer
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) { }
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailView
        
        init(_ parent: MailView) {
            self.parent = parent
        }
        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            controller.dismiss(animated: true)
        }
    }
}
