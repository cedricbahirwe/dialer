//
//  AppleInfo.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 07/11/2024.
//  Copyright © 2024 Cédric Bahirwe. All rights reserved.
//

import Foundation

struct AppleInfo: Codable {
    let userId: String
    let fullname: PersonNameComponents?
    let email: String?
}
