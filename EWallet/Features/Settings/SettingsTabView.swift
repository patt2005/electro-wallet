import SwiftUI
import SafariServices

struct SettingsTabView: View {
    @EnvironmentObject var store: WalletStore
    @EnvironmentObject var lockService: LockService
    @State private var showResetConfirm = false
    @State private var showSeedPhrase = false
    @State private var showPINSetup = false
    @State private var showPINConfirm = false
    @State private var pendingPIN: String = ""
    @State private var showPrivacyPolicy = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Settings")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.textPrimary)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 24)

                // Wallet section
                SettingsSection(title: "WALLET") {
                    SettingsRow(
                        icon: "briefcase.fill",
                        iconColor: Color(red: 59/255, green: 130/255, blue: 246/255),
                        iconBg: Color(red: 59/255, green: 130/255, blue: 246/255).opacity(0.13),
                        title: "Wallet Name"
                    ) {
                        Text("My Wallet")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.textMuted)
                    }

                    SettingsRow(
                        icon: "key.fill",
                        iconColor: Color.btcOrange,
                        iconBg: Color.btcOrange.opacity(0.13),
                        title: "Recovery Phrase"
                    ) {
                        Button {
                            showSeedPhrase = true
                        } label: {
                            Text("View")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.btcGreen)
                        }
                    }

                    SettingsRow(
                        icon: "doc.on.doc.fill",
                        iconColor: Color(red: 139/255, green: 92/255, blue: 246/255),
                        iconBg: Color(red: 139/255, green: 92/255, blue: 246/255).opacity(0.13),
                        title: "Receive Address",
                        isLast: true
                    ) {
                        Text(store.receiveAddress.isEmpty ? "—" : String(store.receiveAddress.prefix(12) + "…"))
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundStyle(Color.textMuted)
                    }
                }

                // Security section
                SettingsSection(title: "SECURITY") {
                    // PIN toggle
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 9)
                                .fill(Color.btcRed.opacity(0.13))
                                .frame(width: 32, height: 32)
                            Image(systemName: "lock.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.btcRed)
                        }
                        Text("App PIN")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.textPrimary)
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
                    .padding(.vertical, 16)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(Color.separator)
                            .frame(height: 1)
                            .padding(.leading, 62)
                    }

                    // Biometric toggle
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 9)
                                .fill(Color(red: 20/255, green: 184/255, blue: 166/255).opacity(0.13))
                                .frame(width: 32, height: 32)
                            Image(systemName: lockService.biometryIcon)
                                .font(.system(size: 14))
                                .foregroundStyle(Color(red: 20/255, green: 184/255, blue: 166/255))
                        }
                        Text(lockService.biometryLabel)
                            .font(.system(size: 16))
                            .foregroundStyle(Color.textPrimary)
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
                    .padding(.vertical, 16)
                }

                // About section
                SettingsSection(title: "ABOUT") {
                    Button {
                        showPrivacyPolicy = true
                    } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 9)
                                    .fill(Color(red: 59/255, green: 130/255, blue: 246/255).opacity(0.13))
                                    .frame(width: 32, height: 32)
                                Image(systemName: "hand.raised.fill")
                                    .font(.system(size: 14))
                                    .foregroundStyle(Color(red: 59/255, green: 130/255, blue: 246/255))
                            }
                            Text("Privacy Policy")
                                .font(.system(size: 16))
                                .foregroundStyle(Color.textPrimary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(Color(red: 194/255, green: 203/255, blue: 196/255))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                    }
                }

                // Danger zone
                SettingsSection(title: "DANGER ZONE", titleColor: Color(red: 207/255, green: 122/255, blue: 116/255)) {
                    Button {
                        showResetConfirm = true
                    } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 9)
                                    .fill(Color(red: 251/255, green: 230/255, blue: 228/255))
                                    .frame(width: 32, height: 32)
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 14))
                                    .foregroundStyle(Color.btcRed)
                            }
                            Text("Delete Wallet")
                                .font(.system(size: 16))
                                .foregroundStyle(Color.btcRed)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                    }
                }

                Text("EWallet · Non-custodial Bitcoin Wallet\nPowered by BitcoinKit.Swift")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(Color.textMuted)
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
        .sheet(isPresented: $showPrivacyPolicy) {
            PrivacyPolicyView()
        }
    }
}

// MARK: - Settings Section

struct SettingsSection<Content: View>: View {
    let title: String
    var titleColor: Color = Color(red: 126/255, green: 140/255, blue: 130/255)
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(titleColor)
                .tracking(1.5)
                .padding(.horizontal, 20)
                .padding(.bottom, 8)

            VStack(spacing: 0) {
                content
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.cardBorder, lineWidth: 1)
            )
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 24)
    }
}

// MARK: - Settings Row

struct SettingsRow<Trailing: View>: View {
    let icon: String
    let iconColor: Color
    let iconBg: Color
    let title: String
    var isLast: Bool = false
    @ViewBuilder let trailing: Trailing

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 9)
                    .fill(iconBg)
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(iconColor)
            }

            Text(title)
                .font(.system(size: 16))
                .foregroundStyle(Color.textPrimary)

            Spacer()

            trailing

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color(red: 194/255, green: 203/255, blue: 196/255))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .overlay(alignment: .bottom) {
            if !isLast {
                Rectangle()
                    .fill(Color.separator)
                    .frame(height: 1)
                    .padding(.leading, 62)
            }
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
                Color.appBackground.ignoresSafeArea()

                VStack(spacing: 24) {
                    if !revealed {
                        // Warning state
                        VStack(spacing: 24) {
                            ZStack {
                                Circle()
                                    .fill(Color.btcOrange.opacity(0.12))
                                    .frame(width: 90, height: 90)
                                Image(systemName: "exclamationmark.shield.fill")
                                    .font(.system(size: 46))
                                    .foregroundStyle(Color.btcOrange)
                            }

                            Text("Show Recovery Phrase?")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(Color.textPrimary)

                            Text("Make sure no one is watching your screen. Anyone who sees this phrase can access your funds.")
                                .font(.system(size: 15))
                                .foregroundStyle(Color.textSecondary)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)

                            Button {
                                withAnimation { revealed = true }
                            } label: {
                                Text("I Understand, Show Phrase")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(Color(red: 239/255, green: 154/255, blue: 30/255))
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .shadow(
                                        color: Color(red: 239/255, green: 154/255, blue: 30/255).opacity(0.35),
                                        radius: 18,
                                        x: 0,
                                        y: 7
                                    )
                            }
                        }
                        .padding(.horizontal, 28)
                    } else {
                        // Show words
                        ScrollView {
                            VStack(spacing: 20) {
                                // Warning banner
                                HStack(alignment: .top, spacing: 10) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 14))
                                        .foregroundStyle(Color.btcOrange)
                                        .padding(.top, 1)
                                    Text("Store offline. Never share. Never photograph.")
                                        .font(.system(size: 13))
                                        .foregroundStyle(Color.warningText)
                                        .lineSpacing(3)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(Color.warningBg)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.warningBorder, lineWidth: 1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 14))

                                LazyVGrid(columns: columns, spacing: 8) {
                                    ForEach(Array(words.enumerated()), id: \.offset) { index, word in
                                        HStack(spacing: 6) {
                                            Text("\(index + 1)")
                                                .font(.system(size: 10, design: .monospaced))
                                                .foregroundStyle(Color.textMuted)
                                                .frame(minWidth: 14, alignment: .leading)
                                            Text(word)
                                                .font(.system(size: 13, weight: .medium, design: .monospaced))
                                                .foregroundStyle(Color.textPrimary)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.8)
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 10)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 14))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(Color.cardBorder, lineWidth: 1)
                                        )
                                    }
                                }
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
                        .foregroundStyle(Color.btcGreen)
                }
            }
        }
    }
}

// MARK: - Privacy Policy Web View

struct PrivacyPolicyView: UIViewControllerRepresentable {
    private let url = URL(string: "https://firebasestorage.googleapis.com/v0/b/nightee-66b26.firebasestorage.app/o/privacy-policy.html?alt=media&token=49ad6702-60a6-47b0-a356-0bfeb7de1f49")!

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        let vc = SFSafariViewController(url: url, configuration: config)
        return vc
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
