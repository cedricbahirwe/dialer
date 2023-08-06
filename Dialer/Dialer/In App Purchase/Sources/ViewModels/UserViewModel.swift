//
//  UserViewModel.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 12/07/2023.
//

import Foundation
import RevenueCat

/* Static shared model for UserView */
class UserViewModel: ObservableObject {
    static let shared = UserViewModel()
    
    /* The latest CustomerInfo from RevenueCat. Updated by PurchasesDelegate whenever the Purchases SDK updates the cache */
    @Published var customerInfo: CustomerInfo? {
        didSet {
            subscriptionActive = customerInfo?.entitlements[RevenueCatConstants.entitlementID]?.isActive == true
        }
    }
    
    /* The latest offerings - fetched from AppDelegate.swift on app launch */
    @Published var offerings: Offerings? = nil
    
    /* Set from the didSet method of customerInfo above, based on the entitlement set in Constants.swift */
    @Published var subscriptionActive: Bool = false
    
    /*
     How to login and identify your users with the Purchases SDK.
     
     These functions mimic displaying a login dialog, identifying the user, then logging out later.
     
     Read more about Identifying Users here: https://docs.revenuecat.com/docs/user-ids
     */
    #warning("Public-facing usernames aren't optimal for user ID's - you should use something non-guessable, like a non-public database ID. For more information, visit https://docs.revenuecat.com/docs/user-ids.")
    func login(userId: String) async {
        _ = try? await Purchases.shared.logIn(userId)
    }
    
    func logout() async {
        /**
         The current user ID is no longer valid for your instance of *Purchases* since the user is logging out, and is no longer authorized to access customerInfo for that user ID.
         
         `logOut` clears the cache and regenerates a new anonymous user ID.
         
         - Note: Each time you call `logOut`, a new installation will be logged in the RevenueCat dashboard as that metric tracks unique user ID's that are in-use. Since this method generates a new anonymous ID, it counts as a new user ID in-use.
         */
        _ = try? await Purchases.shared.logOut()
    }
}
