import SwiftUI

struct ReceiveTabView: View {
    @EnvironmentObject var store: WalletStore
    @State private var copied = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 6) {
                    Text("Receive Bitcoin")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Color.textPrimary)
                    Text("Share your address to receive BTC")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 24)

                // QR Code card
                ZStack {
                    RoundedRectangle(cornerRadius: 26)
                        .fill(Color.white)
                        .shadow(
                            color: Color(red: 15/255, green: 28/255, blue: 20/255).opacity(0.06),
                            radius: 20,
                            x: 0,
                            y: 6
                        )

                    if store.receiveAddress.isEmpty {
                        ProgressView()
                            .tint(Color.btcGreen)
                            .frame(width: 200, height: 200)
                    } else {
                        QRCodeView(store.receiveAddress, size: 200)
                            .padding(26)
                    }
                }
                .frame(width: 252, height: 252)
                .padding(.bottom, 28)

                VStack(spacing: 12) {
                    // Address box
                    HStack(spacing: 10) {
                        Text(store.receiveAddress.isEmpty ? "Generating address…" : store.receiveAddress)
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundStyle(Color.textSecondary)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineSpacing(3)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Button {
                            UIPasteboard.general.string = store.receiveAddress
                            withAnimation(.spring(response: 0.3)) {
                                copied = true
                            }
                            Task {
                                try? await Task.sleep(nanoseconds: 2_200_000_000)
                                withAnimation { copied = false }
                            }
                        } label: {
                            Text(copied ? "✓ Copied" : "Copy")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color.btcGreen)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Color.btcGreenLight)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .disabled(store.receiveAddress.isEmpty)
                        .animation(.easeInOut(duration: 0.2), value: copied)
                    }
                    .padding(16)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.cardBorder, lineWidth: 1)
                    )

                    // Share button
                    ShareLink(item: store.receiveAddress) {
                        Label("Share Address", systemImage: "square.and.arrow.up")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color.btcGreen)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color(red: 207/255, green: 230/255, blue: 215/255), lineWidth: 1.5)
                            )
                    }

                    // Warning banner
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.btcOrange)
                            .padding(.top, 1)

                        Text("Only send Bitcoin (BTC) to this address. Sending other assets will result in permanent loss.")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.warningText)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color.warningBg)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.warningBorder, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.top, 4)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
    }
}
