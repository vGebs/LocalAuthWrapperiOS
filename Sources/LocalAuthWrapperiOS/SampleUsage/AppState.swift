//
//  File.swift
//  
//
//  Created by Vaughn on 2023-01-19.
//

import Combine
import LocalAuthentication

@available(iOS 13.0, *)
class AppState: ObservableObject {
    
    static let shared = AppState()
    
    var localAuth: LocalAuth
    
    @Published var allowAccess = false
    
    private init() {
        let context = LAContext()
        self.localAuth = LocalAuth(context: context)
    }
    
    func login() {
        localAuth.authenticateUser(reason: "Please login to continue") { [weak self] success, error in
            if success {
                DispatchQueue.main.async {
                    self?.allowAccess = true
                }
            } else {
                if let error = error {
                    switch error {
                    case LAError.userCancel:
                        print("Authentication was cancelled by user.")
                    case LAError.authenticationFailed:
                        print("Authentication failed.")
                    case LAError.passcodeNotSet:
                        print("A passcode has not been set.")
                    case LAError.systemCancel:
                        print("Authentication was cancelled by the system.")
                    case LAError.biometryNotAvailable:
                        print("Biometry is not available.")
                    case LAError.biometryNotEnrolled:
                        print("Biometry has no enrolled identities.")
                    default:
                        print("Authentication failed with error: \(error)")
                    }
                } else {
                    print("Auth Failed")
                }
            }
        }
    }
    
    func logout() {
        let context = LAContext()
        localAuth.invalidateSession(newContext: context)
        self.allowAccess = false
    }
}

