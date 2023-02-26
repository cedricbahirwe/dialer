//
//  LocationManager.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 26/02/2023.
//

import Foundation
import CoreLocation
import SwiftUI

final class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    @Published var authorisationStatus: CLAuthorizationStatus = .notDetermined

    var permissionStatus: LocationStatus {
        switch authorisationStatus {
        case .authorizedAlways, .authorizedWhenInUse: return .granted
        default: return .denied
        }
    }

    override init() {
        super.init()
        self.locationManager.delegate = self
    }

    private func getLastKnownLocation() -> UserLocation? {
        DialerStorage.shared.getLastKnownLocation()
    }

    public func requestAuthorisation(always: Bool = false) async {
        if always {
            do {
                try await locationManager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "")
            } catch {
                authorisationStatus = .notDetermined
            }
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    private func getLatestLocation() -> UserLocation? {
        guard permissionStatus == .granted,
              let location = locationManager.location
        else { return getLastKnownLocation() }
        return UserLocation(location)
    }

    enum LocationStatus: String, Codable {
        case granted
        case denied
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let newAuthorizationStatus = manager.authorizationStatus
//        let accuracy = manager.accuracyAuthorization
        DispatchQueue.main.async {
            self.authorisationStatus = newAuthorizationStatus

            if newAuthorizationStatus == .authorizedWhenInUse || newAuthorizationStatus == .authorizedAlways {
                manager.startUpdatingLocation()
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        DispatchQueue.main.async {
            guard let lastLocation = locations.last else { return }
            let userLocation = UserLocation(lastLocation)
            try? DialerStorage.shared.saveLastKnownLocation(userLocation)
        }
    }
}


// MARK: - Merchant Side
extension LocationManager {
    /// MARK:  - Get merchants near user location
    func getNearbyMerchants() -> [Merchant] {
        guard let location = getLastKnownLocation() else { return [] }
        return []
    }
}
