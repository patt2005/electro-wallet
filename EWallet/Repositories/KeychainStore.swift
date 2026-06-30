import Foundation
import Security

enum KeychainError: LocalizedError {
    case saveFailed(OSStatus)
    case loadFailed(OSStatus)
    case dataConversionFailed

    var errorDescription: String? {
        switch self {
        case .saveFailed(let s): return "Keychain save failed: \(s)"
        case .loadFailed(let s): return "Keychain load failed: \(s)"
        case .dataConversionFailed: return "Could not decode keychain data"
        }
    }
}

struct KeychainStore {
    private static let service = "com.ewallet.bitcoin"
    private static let account = "seed-words"

    static func save(words: [String]) throws {
        let phrase = words.joined(separator: " ")
        guard let data = phrase.data(using: .utf8) else {
            throw KeychainError.dataConversionFailed
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        // Delete any existing entry first
        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }

    static func load() -> [String]? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let phrase = String(data: data, encoding: .utf8) else {
            return nil
        }

        let words = phrase.split(separator: " ").map(String.init)
        return words.isEmpty ? nil : words
    }

    static func delete() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }

    static func exists() -> Bool {
        load() != nil
    }
}
