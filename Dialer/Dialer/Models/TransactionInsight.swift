//
//  TransactionInsight.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 17/09/2024.
//  Copyright © 2024 Cédric Bahirwe. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct TransactionInsight: Codable {
    @DocumentID private var id: String?
    let details: RecordDetails
    let type: RecordType
    var ownerID: UUID
    let createdDate: Date

    var amount: Int {
        switch details {
        case .momo(let transaction):
            transaction.amount
        case .airtime(let purchaseDetailModel):
            purchaseDetailModel.amount
        case .other:
            0
        }
    }

    private enum CodingKeys: String, CodingKey {
        case id, ownerID, type, details, createdDate
    }

    init(
        id: String? = nil,
        createdDate: Date = Date(),
        details: RecordDetails,
        ownerID: UUID
    ) {
        self.id = id
        self.details = details
        self.ownerID = ownerID
        self.type = details.type
        self.createdDate = createdDate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.ownerID = try container.decode(UUID.self, forKey: .ownerID)
        self.type = try container.decode(RecordType.self, forKey: .type)
        self.createdDate = try container.decode(Date.self, forKey: .createdDate)
        self.details = try RecordDetails(from: decoder)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(ownerID, forKey: .ownerID)
        try container.encode(type, forKey: .type)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(details, forKey: .details)
    }
}

enum RecordDetails: Codable {
    case momo(Transaction)
    case airtime(PurchaseDetailModel)
    case other
    private enum CodingKeys: String, CodingKey {
        case type, details
    }

    var type: RecordType {
        switch self {
        case .momo(let transaction):
            return transaction.type == .client ? .user : .merchant
        case .airtime: return .airtime
        case .other: return .other
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rawType = try container.decode(RecordType.self, forKey: .type)
        let dataDecoder = try container.superDecoder(forKey: .details)

        switch rawType {
        case .merchant, .user:
            self = .momo(try Transaction(from: dataDecoder))
        case .airtime:
            self = .airtime(try PurchaseDetailModel(from: dataDecoder))
        case .other:
            self = .other
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .momo(let transaction):
            try transaction.encode(to: encoder)
        case .airtime(let purchase):
            try purchase.encode(to: encoder)
        case .other:
            try container.encodeNil(forKey: .details)
        }
    }
}
enum  RecordType: String, Codable {
    case merchant
    case user
    case airtime
    case other
}
