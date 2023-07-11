//
//  BiometricAuthenticator.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 13/04/2022.
//

import LocalAuthentication

typealias BiometricsAuth = BiometricAuthenticator

final class BiometricAuthenticator {
    /// An authentication context stored at class scope so it's available for use during UI updates.
    private var context = LAContext()

    static var shared = BiometricAuthenticator()

    /// The current authentication state.
    //    @Published var state = AuthenticationState.loggedout

    private init() {
        // The biometryType, which affects this app's UI when state changes, is only meaningful
        //  after running canEvaluatePolicy. But make sure not to run this test from inside a
        //  policy evaluation callback (for example, don't put next line in the state's didSet
        //  method, which is triggered as a result of the state change made in the callback),
        //  because that might result in deadlock.
        context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
    }

    /// Observe biometrics authentication changes
    @MainActor func onStateChanged() async -> Bool {
        // Get a fresh context for each login. If you use the same context on multiple attempts
        //  (by commenting out the next line), then a previously successful authentication
        //  causes the next policy evaluation to succeed without testing biometry again.
        //  That's usually not what you want.
        context = LAContext()

        // First check if we have the needed hardware support.
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {

            let reason = "Authenticate to access this feature."
            
            do {
                // Move to the main thread because a state update triggers UI changes.
                return try await context.evaluatePolicy(.deviceOwnerAuthentication,
                                                        localizedReason: reason)
                
            } catch {
                Log.debug(error.localizedDescription)
                return false
            }
        } else {
            Log.debug(error?.localizedDescription ?? "Can't evaluate policy")
            return false
        }
    }
}
