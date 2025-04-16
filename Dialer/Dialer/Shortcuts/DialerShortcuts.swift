//
//  DialerShortcuts.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 08/01/2025.
//  Copyright © 2025 Cédric Bahirwe. All rights reserved.
//

import Foundation
import AppIntents

@available(iOS 18.0, *)
struct BuyAirtimeIntent: AppIntent {
    static let title: LocalizedStringResource = "Buy airtime"

    @Parameter(
        title: "airtime amount",
        inclusiveRange: (100, 10_000),
        requestValueDialog: .init("How much airtime do you want?")
    )
    var amount: Int

    func perform() async throws -> some IntentResult & OpensIntent {
        let airtimTransaction = AirtimeTransaction(amount: amount)

        if let ussdUrl = try? airtimTransaction.getUSSDURL() {
            let openURLIntent = OpenURLIntent(ussdUrl)
            return .result(opensIntent: openURLIntent)
        } else {
            throw DialingError.invalidUSSD
        }
    }
}

@available(iOS 18.0, *)
struct TranferMoneyIntent: AppIntent {
    static let title: LocalizedStringResource = "Send money"

    @Parameter(
        title: "Transaction Type",
        requestValueDialog: .init("What type of transaction?")
    )
    var type: Transaction.TransactionType

    @Parameter(
        title: "Transaction Number",
        requestValueDialog: .init("To who?")
    )
    var number: String

    @Parameter(
        title: "Transaction Amount",
        inclusiveRange: (100, 1_000_000),
        requestValueDialog: .init("How much?")
    )
    var amount: Int

    var transaction: Transaction.Model {
        Transaction.Model(
            amount: "\(amount)",
            number: number,
            type: type,
            isOptimized: false
        )
    }
    static private var contactName: String?
    func validate() async throws {
        _ = try? await PhoneContacts.getMtnContacts(requestIfNeeded: false)

        guard amount > 0 else {
            throw ValidationError("Amount must be greater than zero.")
        }

        switch type {
        case .client:
            Self.contactName = PhoneContacts.shared.getContactName(for: transaction.toParent())

            if Self.contactName == nil {
                if let matchedContact = PhoneContacts.shared.getContactByName(number),
                   !matchedContact.phoneNumbers.isEmpty {
                    Self.contactName = matchedContact.names
                    number = matchedContact.phoneNumbers[0]
                } else {
                    guard number.count >= 8 else {
                        throw ValidationError("Invalid phone number. Please enter a valid phone number.")
                    }
                }
            }

        case .merchant:
            number = number.removingEmptySpaces
            guard number.allSatisfy(\.isWholeNumber),
                (AppConstants.merchantDigitsRange).contains(number.count) else {
                throw ValidationError("Merchant code is invalid. Please enter a valid merchant code.")
            }
        }
    }

    func perform() async throws -> some IntentResult & OpensIntent {
        try await validate()

        try await requestConfirmation(
            actionName: .send,
            dialog: "Do you want to send \(transaction.amount) RWF to \(Self.contactName ?? transaction.number)?"
        )
        if let ussdUrl = URL(string: "tel://\(transaction.fullCode)") {
            let openURLIntent = OpenURLIntent(ussdUrl)
            return .result(opensIntent: openURLIntent)
        } else {
            throw DialingError.invalidUSSD
        }
    }
}

@available(iOS 18.0, *)
struct DialerShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: BuyAirtimeIntent(),
            phrases: [
                "Buy \(.applicationName) airtime",
                "Get airtime on \(.applicationName)",
                "Buy airtime on \(.applicationName)",
                "Buy airtime with \(.applicationName)",
                "\(.applicationName) airtime"
            ],
            shortTitle: "Buy airtime",
            systemImageName: "simcard"
        )
        AppShortcut(
            intent: TranferMoneyIntent(),
            phrases: [
                "Send money with \(.applicationName)",
                "Pay with \(.applicationName)",
                "Transfer money with \(.applicationName)",
                "Send payment using \(.applicationName)",
                "Pay someone with \(.applicationName)",
                "Make a transfer in \(.applicationName)",
            ],
            shortTitle: "Send Money",
            systemImageName: "paperplane.circle"
        )
    }
}

extension Transaction.TransactionType: AppEnum {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = TypeDisplayRepresentation(stringLiteral: "Transaction Type")
    
    static var caseDisplayRepresentations: [Transaction.TransactionType : DisplayRepresentation] {
        [
            .client: "Client",
            .merchant: "Merchant"
        ]
    }
}

struct ValidationError: LocalizedError {
    var errorDescription: String?

    init(_ description: String) {
        self.errorDescription = description
    }
}
