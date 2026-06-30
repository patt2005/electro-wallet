import Foundation
import LocalAuthentication
import Combine

@MainActor
final class LockService: ObservableObject {

    @Published var isBiometricEnabled: Bool {
        didSet { UserDefaults.standard.set(isBiometricEnabled, forKey: "biometricEnabled") }
    }

    @Published var isPINEnabled: Bool {
        didSet { UserDefaults.standard.set(isPINEnabled, forKey: "pinEnabled") }
    }

    @Published var isUnlocked: Bool = false

    var biometryType: LABiometryType {
        let ctx = LAContext()
        _ = ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        return ctx.biometryType
    }

    var biometryLabel: String {
        switch biometryType {
        case .faceID:  return "Face ID"
        case .touchID: return "Touch ID"
        default:       return "Biometrics"
        }
    }

    var biometryIcon: String {
        switch biometryType {
        case .faceID:  return "faceid"
        case .touchID: return "touchid"
        default:       return "lock.fill"
        }
    }

    var requiresLock: Bool { isBiometricEnabled || isPINEnabled }

    init() {
        isBiometricEnabled = UserDefaults.standard.bool(forKey: "biometricEnabled")
        isPINEnabled = UserDefaults.standard.bool(forKey: "pinEnabled")
        // If no lock is configured, start unlocked
        isUnlocked = !(isBiometricEnabled || isPINEnabled)
    }

    // MARK: - Authenticate

    func authenticate() async {
        guard requiresLock else {
            isUnlocked = true
            return
        }

        if isBiometricEnabled {
            await authenticateWithBiometrics()
        } else if isPINEnabled {
            // PIN UI is handled by PINEntryView — just mark unlocked after it succeeds
        }
    }

    func authenticateWithBiometrics() async {
        let ctx = LAContext()
        var error: NSError?
        guard ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return
        }
        do {
            let success = try await ctx.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Unlock Electro Wallet"
            )
            if success { isUnlocked = true }
        } catch {
            // User cancelled or failed — stay locked
        }
    }

    func savePIN(_ pin: String) {
        UserDefaults.standard.set(pin, forKey: "walletPIN")
        isPINEnabled = true
    }

    func verifyPIN(_ pin: String) -> Bool {
        return UserDefaults.standard.string(forKey: "walletPIN") == pin
    }

    func clearPIN() {
        UserDefaults.standard.removeObject(forKey: "walletPIN")
        isPINEnabled = false
    }

    func lock() {
        if requiresLock { isUnlocked = false }
    }
}
