//
//  SceneDelegate.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 08/02/2021.
//

import UIKit
import SwiftUI

@MainActor
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    /// Environment Objects
    let forceUpdateManager = ForceUpdateManager()
    let merchantStore = MerchantStore()
    let userMerchantStore = UserMerchantStore()
    let userStore = UserStore()
    let insightsStore = DialerInsightStore()
    let mySpaceVM = MySpaceViewModel()

    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let contentView = ContentView()
            .environmentObject(merchantStore)
            .environmentObject(userStore)
            .environmentObject(userMerchantStore)
            .environmentObject(mySpaceVM)
            .environmentObject(insightsStore)
            .environmentObject(forceUpdateManager)
        
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}
