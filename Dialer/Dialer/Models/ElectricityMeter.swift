//
//  ElectricityMeter.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 05/01/2022.
//

import Foundation

struct ElectricityMeter: Equatable, Identifiable, Codable {
    
    let number: String
    var id: String { number }
    
    init(_ number: String) throws {
        let cleanValue = Self.cleanNumber(number)
        guard cleanValue.isEmpty == false else { throw MeterNumberError.emptyMeterNumber }
        guard cleanValue.allSatisfy(\.isNumber) else { throw MeterNumberError.invalidMeterNumber }
        
        self.number = cleanValue
    }
    
    enum MeterNumberError: String, Error {
        case emptyMeterNumber = "Meter can not be empty."
        case invalidMeterNumber = "Meter Number should only contains digits between 0-9."
        
    }
    
}

extension ElectricityMeter {
    private static func cleanNumber(_ number: String) -> String {
        // Remove middle white spaces
        var cleanNumber = number.replacingOccurrences(of: " ", with: "")
        
        // Trim white spaces and new lines
        cleanNumber = cleanNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return cleanNumber
    }
}
