//
//  SceneDelegate.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 08/02/2021.
//

import UIKit
import SwiftUI

var shortcutItemToProcess: UIApplicationShortcutItem?
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    // List of known shortcut actions.
    enum ActionType: String {
        case balanceAction = "BalanceAction"
        case dialAction = "DialAction"
    }
    
    static let codeIdentifierInfoKey = "CodeIdentifier"


    var window: UIWindow?
    var savedShortCutItem: UIApplicationShortcutItem!
    
    let viewModel = MainViewModel()
    
    /// - Tag: willConnectTo
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        /** Process the quick action if the user selected one to launch the app.
            Grab a reference to the shortcutItem to use in the scene.
        */
        if let shortcutItem = connectionOptions.shortcutItem {
            // Save it off for later when we become active.
            savedShortCutItem = shortcutItem
        }
        
        
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView().environmentObject(viewModel)

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
    
    /** Called when the user activates your application by selecting a shortcut on the Home Screen,
        and the window scene is already connected.
    */
    /// - Tag: PerformAction
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        let handled = handleShortCutItem(shortcutItem: shortcutItem)
        completionHandler(handled)
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        if savedShortCutItem != nil {
            _ = handleShortCutItem(shortcutItem: savedShortCutItem)
        }
    }

    
    func sceneWillResignActive(_ scene: UIScene) {
        // Transform most used command into a UIApplicationShortcutItem.
        let application = UIApplication.shared
        
        let codes = viewModel.recentCodes.filter({ $0.count >= 10 })
        
        application.shortcutItems = codes.map({ code -> UIApplicationShortcutItem in
            return UIApplicationShortcutItem(type: ActionType.dialAction.rawValue,
                                             localizedTitle: "Buy for \(code.detail.amount)",
                                             localizedSubtitle: "\(code.detail.fullCode)",
                                             icon: UIApplicationShortcutIcon(systemImageName: "phone.fill"),
                                             userInfo: code.quickActionUserInfo)
            
        })
        
        // Only take the four first shortcuts
//        if let shortcutCount = application.shortcutItems?.count, shortcutCount > 4 {
//            application.shortcutItems = Array(application.shortcutItems!.prefix(4))
//        }
        
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        viewModel.retrieveCodes()
        viewModel.retrieveUSSDCodes()
        DialerStorage.shared.storeSyncDate()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
//        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        viewModel.saveRecentCodesLocally()

    }
    
    func handleShortCutItem(shortcutItem: UIApplicationShortcutItem) -> Bool {
        /** In this sample an alert is being shown to indicate that the action has been triggered,
            but in real code the functionality for the quick action would be triggered.
        */
        if let actionTypeValue = ActionType(rawValue: shortcutItem.type) {
            switch actionTypeValue {
            case .balanceAction:
                viewModel.checkMobileWalletBalance()
                
            case .dialAction:
                // Go to that particular code shortcut.
                if let codeIdentifier = shortcutItem.userInfo?[SceneDelegate.codeIdentifierInfoKey] as? String {
                    // Find the code from the userInfo identifier.
                    if let foundRecentCode = viewModel.rencentDialCode(codeIdentifier) {
                        viewModel.performRecentDialing(for: foundRecentCode)
                    }
                }
                
            }
        }
        return true
    }

}

