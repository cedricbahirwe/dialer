//
//  CodePin.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 28/10/2022.
//

import Foundation

// https://www.gsmarena.com/glossary.php3?term=pin-code
struct CodePin: Codable {
    private let digits: [Int]
    private static let maxLength: Int = 5

    private init(digits: [Int]) throws {
        guard digits.count == CodePin.maxLength else {
            throw ValidationError.invalidCount(digits.count)
        }
        guard digits.allSatisfy({ (0...9).contains($0) }) else {
            throw ValidationError.invalidDigits
        }
        self.digits = digits
    }

    init(_ value: String) throws {
        let parsedDigits = value.compactMap { $0.wholeNumberValue }
        try self.init(digits: parsedDigits)
    }

    init(_ value: Int) throws {
        let parsedDigits = String(value).compactMap { $0.wholeNumberValue }
        try self.init(digits: parsedDigits)
    }
}

extension CodePin {
    var asString: String { digits.map(String.init).joined() }
    
    enum ValidationError: Error {
        case invalidCharacters
        case invalidCount(Int)
        case invalidDigits
    }
}
