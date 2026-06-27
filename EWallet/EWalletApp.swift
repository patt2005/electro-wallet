//
//  EWalletApp.swift
//  EWallet
//

import SwiftUI

@main
struct EWalletApp: App {
    @StateObject private var store = WalletStore()
    @StateObject private var lockService = LockService()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .environmentObject(lockService)
                .preferredColorScheme(.light)
        }
    }
}
