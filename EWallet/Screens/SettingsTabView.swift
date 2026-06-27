import SwiftUI

struct SettingsTabView: View {
    @EnvironmentObject var store: WalletStore
    @EnvironmentObject var lockService: LockService
    @State private var showResetConfirm = false
    @State private var showSeedPhrase = false
    @State private var showPINSetup = false
    @State private var showPINConfirm = false
    @State private var pendingPIN: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Settings")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color(.label))
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 20)

                // Wallet section
                SettingsSection(title: "Wallet") {
                    SettingsRow(icon: "briefcase.fill", iconColor: Color.btcBlue, title: "Wallet Name") {
                        Text("My Wallet")
                            .font(.system(size: 14))
                            .foregroundStyle(Color(.secondaryLabel))
                    }

                    SettingsRow(icon: "key.fill", iconColor: Color.btcOrange, title: "Recovery Phrase") {
                        Button {
                            showSeedPhrase = true
                        } label: {
                            Text("View")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.btcGreen)
                        }
                    }

                    SettingsRow(icon: "doc.on.doc.fill", iconColor: Color(.systemPurple), title: "Receive Address") {
                        Text(store.receiveAddress.isEmpty ? "—" : String(store.receiveAddress.prefix(12) + "…"))
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundStyle(Color(.secondaryLabel))
                    }
                }

                // Security section
                SettingsSection(title: "Security") {
                    // PIN toggle
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 7)
                                .fill(Color.btcRed.opacity(0.15))
                                .frame(width: 30, height: 30)
                            Image(systemName: "lock.fill")
                                .font(.system(size: 13))
                                .foregroundStyle(Color.btcRed)
                        }
                        Text("App PIN")
                            .font(.system(size: 15))
                            .foregroundStyle(Color(.label))
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { lockService.isPINEnabled },
                            set: { enabled in
                                if enabled {
                                    showPINSetup = true
                                } else {
                                    lockService.clearPIN()
                                }
                            }
                        ))
                        .tint(Color.btcGreen)
                        .labelsHidden()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .overlay(alignment: .bottom) { Divider().padding(.leading, 58) }

                    // Biometric toggle
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 7)
                                .fill(Color(.systemTeal).opacity(0.15))
                                .frame(width: 30, height: 30)
                            Image(systemName: lockService.biometryIcon)
                                .font(.system(size: 13))
                                .foregroundStyle(Color(.systemTeal))
                        }
                        Text(lockService.biometryLabel)
                            .font(.system(size: 15))
                            .foregroundStyle(Color(.label))
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { lockService.isBiometricEnabled },
                            set: { enabled in
                                if enabled {
                                    Task { await lockService.authenticateWithBiometrics()
                                        if lockService.isUnlocked {
                                            lockService.isBiometricEnabled = true
                                        }
                                    }
                                } else {
                                    lockService.isBiometricEnabled = false
                                }
                            }
                        ))
                        .tint(Color.btcGreen)
                        .labelsHidden()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }

                // About section
                SettingsSection(title: "About") {
                    SettingsRow(icon: "info.circle.fill", iconColor: Color(.systemGray), title: "Version") {
                        Text("1.0.0")
                            .font(.system(size: 14))
                            .foregroundStyle(Color(.secondaryLabel))
                    }
                }

                // Danger zone
                SettingsSection(title: "Danger Zone") {
                    Button {
                        showResetConfirm = true
                    } label: {
                        HStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 7)
                                    .fill(Color.btcRed.opacity(0.15))
                                    .frame(width: 30, height: 30)
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color.btcRed)
                            }
                            Text("Delete Wallet")
                                .font(.system(size: 15))
                                .foregroundStyle(Color.btcRed)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                    }
                }

                Text("Electro Wallet · Non-custodial Bitcoin Wallet\nPowered by BitcoinKit.Swift")
                    .font(.system(size: 11))
                    .foregroundStyle(Color(.tertiaryLabel))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
            }
        }
        .confirmationDialog("Delete Wallet", isPresented: $showResetConfirm, titleVisibility: .visible) {
            Button("Delete Wallet & Keys", role: .destructive) {
                store.resetWallet()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete your wallet from this device. Make sure you have your seed phrase backed up.")
        }
        .sheet(isPresented: $showSeedPhrase) {
            SeedPhraseRevealView()
        }
        .sheet(isPresented: $showPINSetup) {
            PINSetupFlow()
        }
    }
}

// MARK: - Settings Section

struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color(.secondaryLabel))
                .tracking(1)
                .textCase(.uppercase)
                .padding(.horizontal, 36)
                .padding(.bottom, 8)

            VStack(spacing: 0) {
                content
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 24)
    }
}

// MARK: - Settings Row

struct SettingsRow<Trailing: View>: View {
    let icon: String
    let iconColor: Color
    let title: String
    @ViewBuilder let trailing: Trailing

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 7)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 30, height: 30)
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundStyle(iconColor)
            }

            Text(title)
                .font(.system(size: 15))
                .foregroundStyle(Color(.label))

            Spacer()

            trailing

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color(.tertiaryLabel))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .overlay(alignment: .bottom) {
            Divider().padding(.leading, 58)
        }
    }
}

// MARK: - Seed Phrase Reveal

struct SeedPhraseRevealView: View {
    @Environment(\.dismiss) var dismiss
    @State private var revealed = false

    private var words: [String] {
        KeychainStore.load() ?? []
    }

    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                VStack(spacing: 24) {
                    if !revealed {
                        // Warning state
                        VStack(spacing: 20) {
                            Image(systemName: "exclamationmark.shield.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(Color.btcOrange)

                            Text("Show Recovery Phrase?")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(Color(.label))

                            Text("Make sure no one is watching your screen. Anyone who sees this phrase can access your funds.")
                                .font(.system(size: 15))
                                .foregroundStyle(Color(.secondaryLabel))
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)

                            Button {
                                withAnimation { revealed = true }
                            } label: {
                                Text("I Understand, Show Phrase")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 17)
                                    .background(Color.btcOrange)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                        }
                        .padding(.horizontal, 28)
                    } else {
                        // Show words
                        ScrollView {
                            VStack(spacing: 16) {
                                LazyVGrid(columns: columns, spacing: 8) {
                                    ForEach(Array(words.enumerated()), id: \.offset) { index, word in
                                        HStack(spacing: 7) {
                                            Text("\(index + 1)")
                                                .font(.system(size: 11, weight: .semibold))
                                                .foregroundStyle(Color(.secondaryLabel))
                                                .frame(minWidth: 14, alignment: .leading)
                                            Text(word)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundStyle(Color(.label))
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.8)
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 10)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color(.systemBackground))
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                }

                                Text("Store offline. Never share. Never photograph.")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color(.tertiaryLabel))
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(4)
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
                .padding(.top, 20)
            }
            .navigationTitle("Recovery Phrase")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    SettingsTabView()
        .environmentObject(WalletStore())
}
