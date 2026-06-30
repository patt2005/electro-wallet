import SwiftUI

struct WelcomeView: View {
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Logo + branding
                VStack(spacing: 28) {
                    // Bitcoin logo mark
                    ZStack {
                        // Glow layer
                        RoundedRectangle(cornerRadius: 24)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 35/255, green: 178/255, blue: 95/255),
                                        Color(red: 11/255, green: 120/255, blue: 56/255)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 84, height: 84)
                            .blur(radius: 18)
                            .opacity(0.45)

                        RoundedRectangle(cornerRadius: 24)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 35/255, green: 178/255, blue: 95/255),
                                        Color(red: 11/255, green: 120/255, blue: 56/255)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 84, height: 84)

                        Text("₿")
                            .font(.system(size: 46, weight: .bold))
                            .foregroundStyle(.white)
                    }

                    VStack(spacing: 8) {
                        Text("EWallet")
                            .font(.system(size: 42, weight: .bold, design: .default))
                            .tracking(-1.8)
                            .foregroundStyle(Color.textPrimary)

                        Text("BITCOIN WALLET")
                            .font(.system(size: 12, design: .monospaced))
                            .tracking(2.5)
                            .foregroundStyle(Color(red: 102/255, green: 117/255, blue: 107/255))
                    }

                    Text("Self-custody · Open source · Secure")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.textMuted)
                        .multilineTextAlignment(.center)
                }

                Spacer()

                // Buttons
                VStack(spacing: 13) {
                    NavigationLink(destination: CreateWalletView()) {
                        Text("Create New Wallet")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.btcGreen)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color.btcGreen.opacity(0.32), radius: 22, x: 0, y: 8)
                    }

                    NavigationLink(destination: ImportWalletView()) {
                        Text("Import Existing Wallet")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Color.btcGreen)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(red: 207/255, green: 230/255, blue: 215/255), lineWidth: 1.5)
                            )
                    }

                    Text("NON-CUSTODIAL · OPEN SOURCE")
                        .font(.system(size: 11, design: .monospaced))
                        .tracking(1.5)
                        .foregroundStyle(Color.textMuted)
                        .padding(.top, 6)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 52)
            }
        }
        .navigationBarHidden(true)
    }
}

