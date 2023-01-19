import Foundation
import LocalAuthentication

public enum BiometryType {
    case faceID
    case touchID
    case passphrase
}

public class LocalAuth {
    
    private var context: LAContext
    var biometryType: BiometryType?
    
    public init(context: LAContext) {
        self.context = context
        checkSupport()
    }

    public func authenticateUser(reason: String, completion: @escaping (Bool, Error?) -> Void) {
        if biometryType == .faceID || biometryType == .touchID {
            authenticateWithBiometry(reason: reason, completion: completion)
        } else if biometryType == .passphrase {
            authenticateWithPassphrase(reason: reason, completion: completion)
        } else {
            completion(false, nil)
        }
    }

    public func invalidateSession(newContext: LAContext) {
        context.invalidate()
        self.context = newContext
    }
    
    public func checkBiometryStatus() -> (Bool, BiometryType?) {
        return (biometryType != nil, biometryType)
    }

    private func authenticateWithBiometry(reason: String, completion: @escaping (Bool, Error?) -> Void) {
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { (success, error) in
            completion(success, error)
        }
    }

    private func authenticateWithPassphrase(reason: String, completion: @escaping (Bool, Error?) -> Void) {
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { (success, error) in
            completion(success, error)
        }
    }
    
    private func checkSupport(){
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            if #available(iOS 11.0, *) {
                switch context.biometryType {
                case .faceID:
                    biometryType = .faceID
                case .touchID:
                    biometryType = .touchID
                default:
                    biometryType = nil
                }
            } else {
                biometryType = .faceID
            }
        } else if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            biometryType = .passphrase
        } else {
            biometryType = nil
        }
    }
}
