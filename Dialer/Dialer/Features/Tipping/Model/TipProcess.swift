//
//  TipProcess.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 01/10/2025.
//  Copyright © 2025 Cédric Bahirwe. All rights reserved.
//

import Foundation

enum TipProcess: Equatable {
    case idle
    case processing
    case completed
    case failed(_ errorMessage: String)
}
