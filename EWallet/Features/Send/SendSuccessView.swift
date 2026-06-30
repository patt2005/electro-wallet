import SwiftUI

struct SendSuccessView: View {
    @EnvironmentObject var store: WalletStore
    @Environment(\.dismiss) var dismiss
    @State private var scaleEffect: CGFloat = 0.3
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // Animated checkmark
                ZStack {
                    Circle()
                        .fill(Color.btcGreen.opacity(0.12))
                        .frame(width: 120, height: 120)

                    Circle()
                        .fill(Color.btcGreen.opacity(0.2))
                        .frame(width: 96, height: 96)

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 70))
                        .foregroundStyle(Color.btcGreen)
                }
                .scaleEffect(scaleEffect)
                .opacity(opacity)

                // Text
                VStack(spacing: 8) {
                    Text("Transaction Sent!")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Color(.label))

                    Text("Your Bitcoin has been broadcast to the network.")
                        .font(.system(size: 15))
                        .foregroundStyle(Color(.secondaryLabel))
                        .multilineTextAlignment(.center)

                    Text("Confirmation may take a few minutes depending on network activity.")
                        .font(.system(size: 13))
                        .foregroundStyle(Color(.tertiaryLabel))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                        .lineSpacing(3)
                }

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Text("Back to Wallet")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(Color.btcGreen)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1)) {
                scaleEffect = 1.0
                opacity = 1.0
            }
        }
    }
}

#Preview {
    SendSuccessView()
        .environmentObject(WalletStore())
}
