//
//  AppDelegate.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 08/02/2021.
//

import UIKit

#if DEV
    let SOME_SERVICE_KEY = "SomeKeyForDEV"
#else
    let SOME_SERVICE_KEY = "SomeKeyForPRO"
#endif

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print(SOME_SERVICE_KEY)
        return true
    }
}

