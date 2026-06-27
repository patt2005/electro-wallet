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
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color(.label))
                    Text("Share your address to receive BTC")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(.secondaryLabel))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 20)

                // QR Code
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.white)
                        .shadow(color: .black.opacity(0.12), radius: 20, x: 0, y: 8)

                    if store.receiveAddress.isEmpty {
                        ProgressView()
                            .frame(width: 200, height: 200)
                    } else {
                        QRCodeView(store.receiveAddress, size: 200)
                    }
                }
                .frame(width: 240, height: 240)
                .padding(.bottom, 28)

                VStack(spacing: 12) {
                    // Address box
                    HStack(spacing: 10) {
                        Text(store.receiveAddress.isEmpty ? "Generating address…" : store.receiveAddress)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundStyle(Color(.label))
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
                                .foregroundStyle(copied ? Color.btcGreen : Color.btcGreen)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(copied ? Color.btcGreen.opacity(0.15) : Color.btcGreen.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .disabled(store.receiveAddress.isEmpty)
                        .animation(.easeInOut(duration: 0.2), value: copied)
                    }
                    .padding(16)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color(.separator).opacity(0.5), lineWidth: 1)
                    )

                    // Share button
                    ShareLink(item: store.receiveAddress) {
                        Label("Share Address", systemImage: "square.and.arrow.up")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color(.secondaryLabel))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color(.separator).opacity(0.5), lineWidth: 1)
                            )
                    }

                    Text("Only send Bitcoin (BTC) to this address.\nSending other assets will result in permanent loss.")
                        .font(.system(size: 12))
                        .foregroundStyle(Color(.tertiaryLabel))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
    }
}
