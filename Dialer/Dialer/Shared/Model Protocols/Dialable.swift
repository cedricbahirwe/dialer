//
//  Dialable.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 01/10/2025.
//  Copyright © 2025 Cédric Bahirwe. All rights reserved.
//

import Foundation

protocol Dialable {
    var isValid: Bool { get }
    var fullUSSDCode: String { get }
}
