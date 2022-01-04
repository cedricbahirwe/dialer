//
//  RecentCode.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 04/01/2022.
//

import Foundation

struct RecentCode: Identifiable, Hashable, Codable {
    static func == (lhs: RecentCode, rhs: RecentCode) -> Bool {
        lhs.id == rhs.id
    }
    
    public init(id: UUID = UUID(), detail: PurchaseDetailModel, count: Int = 1) {
        self.id = id
        self.detail = detail
        self.count = count
    }
    
    private(set) var id: UUID
    private(set) var count: Int
    var detail: PurchaseDetailModel
    var totalPrice: Int { detail.amount * count }
    
    mutating func increaseCount() { count += 1 }
    
    static let example = RecentCode(detail: .example)
    
}
