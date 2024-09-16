//
//  TransactionModel.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 14/06/2021.
//

import Foundation

struct Transaction: Identifiable, Codable {
    var id: String { Date().description }
    var amount: String
    var number: String
    var type: TransactionType

    private var trailingCode: String {
        // Need strategy to deal with country code
        number.replacingOccurrences(of: " ", with: "") + "*" + amount
    }


    var doubleAmount: Double {
        Double(amount) ?? 0
    }

    var estimatedFee: Int {
        if type == .client {
            for range in Self.transactionFees {
                if range.key.contains(Int(doubleAmount)) {
                    return range.value
                }
            }
            return -1
        } else {
            return 0
        }
    }

    var fullCode: String {
        if type == .client {
            return "*182*1*1*\(trailingCode)#"
        } else {
            return "*182*8*1*\(trailingCode)#"
        }
    }

    /// Determines whether a transaction is valid
    /// Need better operation to handle edge cases (long/short numbers)
    var isValid: Bool {
        switch type {
        case .client:
            return doubleAmount > 0 && number.count >= 8
        case .merchant:
            // TODO: Needs a firebase remote config to set the merchant digits count
            return doubleAmount > 0 && (AppConstants.merchantDigitsRange).contains(number.count)
        }
    }

    enum TransactionType: String, Codable {
        case client, merchant

        mutating func toggle() {
            self = self == .client ? .merchant : .client
        }
    }

    static let transactionFees = [0...1_000 : 20, 1_001...10_000 : 100, 10_001...150_000 : 250, 150_001...2_000_000 : 15_00]
}


import FirebaseFirestore

enum  RecordType: String, Codable {
    case merchant
    case user
    case airtime
    case other
}

enum RecordDetails: Codable {
    case momo(Transaction)
    case airtime(PurchaseDetailModel)
    case other
    private enum CodingKeys: String, CodingKey {
        case type, data
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rawType = try container.decode(RecordType.self, forKey: .type)
        let dataDecoder = try container.superDecoder(forKey: .data)

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
            let recordType: RecordType = transaction.type == .client ? .user : .merchant
            try container.encode(recordType, forKey: .type)
            try transaction.encode(to: container.superEncoder(forKey: .data))
        case .airtime(let purchase):
            try container.encode(RecordType.airtime, forKey: .type)
            try purchase.encode(to: container.superEncoder(forKey: .data))
        case .other:
            try container.encode(RecordType.other, forKey: .type)
            try container.encodeNil(forKey: .data)
        }
    }
}
protocol RecordableTransaction: Codable {
    var recordType: RecordType { get }
}
struct RecordInsight: Codable {
    @DocumentID private var id: String?

    let details: RecordDetails

    private enum CodingKeys: String, CodingKey {
        case id, details
    }

    init(id: String? = nil, details: RecordDetails) {
        self.id = id
        self.details = details
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.details = try RecordDetails(from: decoder)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(details, forKey: .details)
    }
}
