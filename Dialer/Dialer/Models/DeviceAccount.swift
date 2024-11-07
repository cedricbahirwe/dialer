//
//  DeviceAccount.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 06/05/2023.
//

import Foundation
import FirebaseFirestore

struct DeviceAccount: Codable {
    @DocumentID private var id: String?

    var name: String
    var model: String
    var systemVersion: String
    var systemName: String

    var deviceHash: UUID
    var appVersion: String?
    var bundleVersion: String?
    var bundleId: String?
    var lastVisitedDate: String?

    func toAnalytics() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        dictionary["id"] = id
        dictionary["name"] = name
        dictionary["app_version"] = appVersion
        dictionary["model"] = model
        dictionary["system_version"] = systemVersion
        dictionary["system_name"] = systemName
        dictionary["bundle_version"] = bundleVersion
        return dictionary
    }
    
    init(id: String? = nil, name: String, model: String, systemVersion: String, systemName: String, deviceHash: UUID, appVersion: String?, bundleVersion: String?, bundleId: String?, lastVisitedDate: String?) {
        self.id = id
        self.name = name
        self.model = model
        self.systemVersion = systemVersion
        self.systemName = systemName
        self.deviceHash = deviceHash
        self.appVersion = appVersion
        self.bundleVersion = bundleVersion
        self.bundleId = bundleId
        self.lastVisitedDate = lastVisitedDate
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.deviceHash = try container.decode(UUID.self, forKey: .deviceHash)
        self._id = try container.decodeIfPresent(DocumentID<String>.self, forKey: .id) ?? DocumentID(wrappedValue: deviceHash.uuidString)
        self.name = try container.decode(String.self, forKey: .name)
        self.model = try container.decode(String.self, forKey: .model)
        self.systemVersion = try container.decode(String.self, forKey: .systemVersion)
        self.systemName = try container.decode(String.self, forKey: .systemName)
        self.appVersion = try container.decodeIfPresent(String.self, forKey: .appVersion)
        self.bundleVersion = try container.decodeIfPresent(String.self, forKey: .bundleVersion)
        self.bundleId = try container.decodeIfPresent(String.self, forKey: .bundleId)
        self.lastVisitedDate = try container.decodeIfPresent(String.self, forKey: .lastVisitedDate)
    }
}
