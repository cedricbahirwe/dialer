//
//  LocationManager.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 26/02/2023.
//

import Foundation
import CoreLocation

final class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    @Published var authorisationStatus: CLAuthorizationStatus = .notDetermined
    var status: LocationStatus {
        switch authorisationStatus {
        case .denied: return .denied
        case .authorizedAlways: return .authorizedAlways
        case .authorizedWhenInUse: return .authorizedWhenInUse
        default: return .unknown
        }
    }
    override init() {
        super.init()
        self.locationManager.delegate = self
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

    enum LocationStatus: String, Codable {
        case authorizedAlways
        case authorizedWhenInUse
        case denied
        case unknown
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let newAuthorizationStatus = manager.authorizationStatus
        let accuracy = manager.accuracyAuthorization
        DispatchQueue.main.async {
            self.authorisationStatus = newAuthorizationStatus

            print(manager.location, "Coordinate")
            if newAuthorizationStatus == .authorizedWhenInUse || newAuthorizationStatus == .authorizedAlways {
                manager.startUpdatingLocation()
            }
        }
        print(self.status, accuracy.rawValue)
    }


    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("User Locations", locations.last)
    }
}
