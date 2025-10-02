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

    
    /// - Tag: willConnectTo
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()
            .environmentObject(merchantStore)
            .environmentObject(userStore)
            .environmentObject(userMerchantStore)
            .environmentObject(mySpaceVM)
            .environmentObject(insightsStore)
            .environmentObject(forceUpdateManager)
        
        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        UIApplication.shared.shortcutItems = nil
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
//        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

    }
}
