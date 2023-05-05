//
//  DeviceAccount.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 06/05/2023.
//

import Foundation
import FirebaseFirestoreSwift

struct DeviceAccount: Identifiable, Codable {
    @DocumentID var id: String?

    var name: String
    let model: String
    let systemVersion: String
    let systemName: String

    let deviceHash: String
    let appVersion: String?
    let bundleVersion: String?
    let bundleId: String?
    let lastVisitedDate: String?

    func toDictionary() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        dictionary["name"] = name
        dictionary["model"] = model
        dictionary["system_version"] = systemVersion
        dictionary["system_name"] = systemName
        dictionary["device_hash"] = deviceHash
        dictionary["app_version"] = appVersion
        dictionary["bundle_version"] = bundleVersion
        dictionary["bundle_id"] = bundleId
        dictionary["last_visited_date"] = lastVisitedDate
        return dictionary
    }
}
