//
//  UserLocation.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 26/02/2023.
//

import CoreLocation

struct UserLocation: Codable {
    let latitude: Double
    let longitude: Double

    init(_ location: CLLocation) {
        let coordinate = location.coordinate
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
}
