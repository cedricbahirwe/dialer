//
//  MeterNumber.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 04/01/2022.
//

import Foundation

struct MeterNumber: Equatable, Identifiable, Codable {
    
    static func == (lhs: MeterNumber, rhs: MeterNumber) -> Bool {
        let left = lhs.id.replacingOccurrences(of: " ", with: "")
        let right = rhs.id.replacingOccurrences(of: " ", with: "")
        
        return left == right
    }
    
    let value: String
    var id: String { value }
    
    init(_ value: String) throws {
        guard value.isEmpty == false else { throw MeterNumberError.emptyMeterNumber }
        guard value.allSatisfy(\.isNumber) else { throw MeterNumberError.invalidMeterNumber }
        
        self.value = value
    }
    
    enum MeterNumberError: String, Error {
        case emptyMeterNumber = "Meter can not be empty."
        case invalidMeterNumber = "Meter Number should only contains digits between 0-9."
        
    }
    
}


