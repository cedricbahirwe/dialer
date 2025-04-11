//
//  MockPreview.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 04/06/2023.
//

import Foundation

enum MockPreviewData {
    static let contact1 = Contact(names: "Kate Bell",
                                 phoneNumbers: ["(555) 564-8583", "(415) 555-3695"])
    static let contact2 = Contact(names: "John Smith",
                                 phoneNumbers: ["(415) 555-3695"])
        
    static let emptyPurchase = AirtimeTransaction()

    static let airtimeInsight = TransactionInsight(
        details: .airtime(.init(amount: 1000, purchaseDate: .now)),
        ownerID: .init()
    )

    static let merchantInsight = TransactionInsight(
        details: .momo(.init(amount: 121200, number: "004050", type: .merchant, isOptimized: false)),
        ownerID: .init()
    )

    static let clientInsight = TransactionInsight(
        details: .momo(.init(amount: 15020, number: "0782628511", type: .client, isOptimized: false)),
        ownerID: .init()
    )

    static let merchants = [
        Merchant(Optional("JkSKq9QM4vrBjeZHpg4d"), name: "La gardienne", address: "12 KN 41St, Kigali", code: "004422", ownerId: UUID()),
        Merchant(Optional("eHJNvwKhbdB1sdV19F3P"), name: "Cedrics", address: "", code: "12345", ownerId: UUID()),
        Merchant(Optional("sLcVGrcUfNrNdgq8HJhn"), name: "Emilienne", address: "Gishushu", code: "028508", ownerId: UUID()),
        Merchant(Optional("xW5nAHmPgTmvyohe0XtI"), name: "La gardienne", address: "12 KN 41St, Kigali", code: "004422", ownerId: UUID())
    ]
}
