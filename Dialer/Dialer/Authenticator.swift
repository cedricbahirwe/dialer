//
//  Authenticator.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 16/12/2021.
//

import LocalAuthentication

class BiometricAuthenticator: ObservableObject {
    /// An authentication context stored at class scope so it's available for use during UI updates.
    var context = LAContext()
    
    static var shared = BiometricAuthenticator()
    
    /// The available states of being logged in or not.
    enum AuthenticationState {
        case loggedin, loggedout
    }
    
    /// The current authentication state.
    @Published var state = AuthenticationState.loggedout
    
    private init() {
        // The biometryType, which affects this app's UI when state changes, is only meaningful
        //  after running canEvaluatePolicy. But make sure not to run this test from inside a
        //  policy evaluation callback (for example, don't put next line in the state's didSet
        //  method, which is triggered as a result of the state change made in the callback),
        //  because that might result in deadlock.
        context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        
        
        // Set the initial app state. This impacts the initial state of the UI as well.
        state = .loggedout
    }
    
    
    /// Logs out or attempts to log in.
    public func changeLoginState() {
        if state == .loggedin {
            // Log out immediately.
            state = .loggedout
            changeLoginState()
            
        } else {
            
            // Get a fresh context for each login. If you use the same context on multiple attempts
            //  (by commenting out the next line), then a previously successful authentication
            //  causes the next policy evaluation to succeed without testing biometry again.
            //  That's usually not what you want.
            context = LAContext()
            
//            context.localizedCancelTitle = "Enter Username/Password"
            
            // First check if we have the needed hardware support.
            var error: NSError?
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                
                let reason = "Authenticate to access this feature."
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason ) { success, error in
                    
                    if success {
                        
                        // Move to the main thread because a state update triggers UI changes.
                        DispatchQueue.main.async { [unowned self] in
                            self.state = .loggedin
                        }
                        
                    } else {
                        print(error?.localizedDescription ?? "Failed to authenticate")
                        
                        // Fall back to a asking for username and password.
                        // ...
                    }
                }
            } else {
                print(error?.localizedDescription ?? "Can't evaluate policy")
                
                // Fall back to a asking for username and password.
                // ...
            }
        }
    }
}
