//
//  ContentView.swift (RootView)
//  EWallet
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var store: WalletStore
    @EnvironmentObject var lockService: LockService

    var body: some View {
        Group {
            if store.isLoading || (store.isWalletCreated && !lockService.isUnlocked) {
                SplashView()
            } else if store.isWalletCreated {
                DashboardView()
            } else {
                NavigationStack {
                    WelcomeView()
                }
            }
        }
        .animation(.easeInOut(duration: 0.4), value: store.isLoading)
        .animation(.easeInOut(duration: 0.3), value: lockService.isUnlocked)
        .alert("Error", isPresented: Binding(
            get: { store.errorMessage != nil },
            set: { if !$0 { store.errorMessage = nil } }
        )) {
            Button("OK") { store.errorMessage = nil }
        } message: {
            Text(store.errorMessage ?? "")
        }
    }
}

// MARK: - Splash / Lock View

struct SplashView: View {
    @EnvironmentObject var store: WalletStore
    @EnvironmentObject var lockService: LockService

    @State private var logoScale: CGFloat = 0.7
    @State private var logoOpacity: CGFloat = 0
    @State private var textOpacity: CGFloat = 0
    @State private var showPINEntry = false

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 20) {
                ZStack {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color.btcGreen.opacity(0.12))
                        .frame(width: 100, height: 100)
                    Image(systemName: "bolt.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 42, height: 42)
                        .foregroundStyle(Color.btcGreen)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                VStack(spacing: 6) {
                    Text("Electro Wallet")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(Color(.label))
                    Text("Bitcoin Wallet")
                        .font(.system(size: 16))
                        .foregroundStyle(Color(.secondaryLabel))
                }
                .opacity(textOpacity)

                // Show unlock button if wallet loaded but locked
                if store.isWalletCreated && !store.isLoading && lockService.requiresLock {
                    VStack(spacing: 12) {
                        if lockService.isBiometricEnabled {
                            Button {
                                Task { await lockService.authenticateWithBiometrics() }
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: lockService.biometryIcon)
                                    Text("Unlock with \(lockService.biometryLabel)")
                                        .font(.system(size: 15, weight: .semibold))
                                }
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(Color.btcGreen)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                            .padding(.horizontal, 40)
                        }

                        if lockService.isPINEnabled {
                            Button {
                                showPINEntry = true
                            } label: {
                                Text("Enter PIN")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(Color.btcGreen)
                            }
                        }
                    }
                    .opacity(textOpacity)
                    .padding(.top, 8)
                } else if store.isLoading {
                    ProgressView()
                        .tint(Color.btcGreen)
                        .padding(.top, 4)
                        .opacity(textOpacity)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            withAnimation(.easeIn(duration: 0.4).delay(0.3)) {
                textOpacity = 1.0
            }
            // Auto-trigger biometric after wallet loads
            if store.isWalletCreated && lockService.isBiometricEnabled {
                Task {
                    try? await Task.sleep(nanoseconds: 600_000_000)
                    await lockService.authenticateWithBiometrics()
                }
            }
        }
        .sheet(isPresented: $showPINEntry) {
            PINEntryView(mode: .unlock)
        }
    }
}
