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

    static let clientInsight = TransactionInsight(
        details: .momo(.init(amount: 15020, number: "0782628511", type: .client, isOptimized: false)),
        ownerID: .init()
    )
}
