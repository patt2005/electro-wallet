import SwiftUI

struct WelcomeView: View {
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Logo
                VStack(spacing: 24) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.btcGreen.opacity(0.12))
                            .frame(width: 92, height: 92)

                        Image(systemName: "bolt.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 38, height: 38)
                            .foregroundStyle(Color.btcGreen)
                    }

                    VStack(spacing: 6) {
                        Text("Electro Wallet")
                            .font(.system(size: 34, weight: .bold, design: .default))
                            .foregroundStyle(Color(.label))

                        Text("Bitcoin Wallet")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundStyle(Color(.secondaryLabel))
                    }

                    Text("Self-custody. Open source. Secure.")
                        .font(.system(size: 13))
                        .foregroundStyle(Color(.tertiaryLabel))
                        .multilineTextAlignment(.center)
                }

                Spacer()

                // Buttons
                VStack(spacing: 12) {
                    NavigationLink(destination: CreateWalletView()) {
                        Text("Create New Wallet")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.btcGreen)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    }

                    NavigationLink(destination: ImportWalletView()) {
                        Text("Import Existing Wallet")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Color.btcGreen)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.btcGreen.opacity(0.35), lineWidth: 1)
                            )
                    }

                    Text("Non-custodial · Open source")
                        .font(.system(size: 12))
                        .foregroundStyle(Color(.tertiaryLabel))
                        .padding(.top, 4)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Color Extension

extension Color {
    static let btcGreen = Color(red: 26/255, green: 158/255, blue: 63/255)
    static let btcRed = Color(red: 255/255, green: 59/255, blue: 48/255)
    static let btcOrange = Color(red: 255/255, green: 149/255, blue: 0/255)
    static let btcBlue = Color(red: 30/255, green: 144/255, blue: 255/255)
    static let cardBg = Color(.systemBackground)
    static let separator = Color(.separator).opacity(0.5)
}
