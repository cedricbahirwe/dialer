//
//  AppNotification.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 16/12/2022.
//

import Foundation

protocol AppNotification {
    var id: UUID { get }
    var title: String { get }
    var message: String { get }
    var info: [String: Any] { get }
    var imageUrl: URL? { get }
    var scheduledDate: DateComponents { get }
}
