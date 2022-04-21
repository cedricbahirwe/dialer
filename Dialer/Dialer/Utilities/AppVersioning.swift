//
//  AppVersioning.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 22/09/2021.
//

import SwiftUI

extension UIApplication {
    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    static var buildVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
    }

    static var hasSupportForUSSD: Bool {
        UIDevice.current.systemVersion < "15.4"
    }
}

