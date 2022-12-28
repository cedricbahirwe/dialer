//
//  CodePin.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 28/10/2022.
//

import Foundation

// https://www.gsmarena.com/glossary.php3?term=pin-code
struct CodePin: Codable {
    let a: Int
    let b: Int
    let c: Int
    let d: Int
    let e: Int
    init(_ value: String) throws {
        guard value.allSatisfy({ $0.isWholeNumber }) else {
            throw ValidationError.invalidCharacters
        }

        guard value.count == 5 else {
            throw ValidationError.invalidCount(value.count)
        }

        // # This needs improvements
        let digits = Array(value)
        self.a = digits[0].wholeNumberValue!
        self.b = digits[1].wholeNumberValue!
        self.c = digits[2].wholeNumberValue!
        self.d = digits[3].wholeNumberValue!
        self.e = digits[4].wholeNumberValue!
    }

    init(_ value: Int) throws {
        guard String(value).count == 5 else {
            throw ValidationError.invalidCount(String(value).count)
        }

        // # This needs improvements
        let digits = Array(String(value))
        self.a = digits[0].wholeNumberValue!
        self.b = digits[1].wholeNumberValue!
        self.c = digits[2].wholeNumberValue!
        self.d = digits[3].wholeNumberValue!
        self.e = digits[4].wholeNumberValue!
    }

    var asString: String { "\(a)\(b)\(c)\(d)\(e)" }

    var asDigits: Int { Int(asString) ?? 0 }

    var description: String { asString }

}

extension CodePin {
    enum ValidationError: Error {
        case invalidCharacters
        case invalidCount(Int)
    }
}

extension String {
    init(_ codepin: CodePin) {
        self = codepin.asString
    }
}
