//
//  AppDelegate.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 08/02/2021.
//

import UIKit
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        configureFirebase()
        return true
    }

    private func configureFirebase() {
        let fileName = AppConfiguration.firebaseConfigFileName()
        guard
            let filePath = Bundle.main.path(forResource: fileName, ofType: "plist"),
            let options = FirebaseOptions(contentsOfFile: filePath)
        else {
            Log.debug("Could not find Firebase config file")
            return
        }

        FirebaseApp.configure(options: options)

        _ = Tracker.shared
    }
}
