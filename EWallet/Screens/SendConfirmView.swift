import SwiftUI

struct SendConfirmView: View {
    @EnvironmentObject var store: WalletStore
    @State private var isSending = false

    private var amtBTC: Double { Double(store.sendAmountBTC) ?? 0 }
    private var feeSats: Int { store.estimateFee(feeLevel: store.sendFeeLevel) }
    private var feeBTC: Double { Double(feeSats) / 100_000_000 }
    private var totalBTC: Double { amtBTC + feeBTC }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 24) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color.btcGreen.opacity(0.12))
                        .frame(width: 78, height: 78)
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 42))
                        .foregroundStyle(Color.btcGreen)
                }
                .padding(.top, 8)

                // Summary
                VStack(spacing: 4) {
                    Text("Send")
                        .font(.system(size: 15))
                        .foregroundStyle(Color(.secondaryLabel))
                    Text(String(format: "%.5f BTC", amtBTC))
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(Color(.label))
                    Text("≈ \((amtBTC * store.btcUsdRate).formatted(.currency(code: "USD")))")
                        .font(.system(size: 15))
                        .foregroundStyle(Color(.secondaryLabel))
                }

                // Details card
                VStack(spacing: 0) {
                    ConfirmRow(label: "To") {
                        Text(abbreviate(store.sendAddress))
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundStyle(Color(.label))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }

                    Divider().padding(.leading, 16)

                    ConfirmRow(label: "Amount") {
                        Text(String(format: "%.5f BTC", amtBTC))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color(.label))
                    }

                    Divider().padding(.leading, 16)

                    ConfirmRow(label: "Network Fee") {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(String(format: "%.8f BTC", feeBTC))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color(.label))
                            Text(store.sendFeeLevel.rawValue + " · " + store.sendFeeLevel.estimatedTime)
                                .font(.system(size: 11))
                                .foregroundStyle(Color(.secondaryLabel))
                        }
                    }

                    Divider().padding(.leading, 16)

                    ConfirmRow(label: "Total") {
                        Text(String(format: "%.8f BTC", totalBTC))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.btcRed)
                    }
                }
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(.separator).opacity(0.5), lineWidth: 1)
                )
                .padding(.horizontal, 20)

                Spacer()

                // Confirm button
                VStack(spacing: 12) {
                    Button {
                        Task { await sendTransaction() }
                    } label: {
                        if isSending {
                            ProgressView()
                                .tint(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 17)
                        } else {
                            Text("Confirm & Send")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 17)
                        }
                    }
                    .background(Color.btcGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .disabled(isSending)
                    .padding(.horizontal, 20)

                    Text("Transactions cannot be reversed once broadcast to the network.")
                        .font(.system(size: 12))
                        .foregroundStyle(Color(.tertiaryLabel))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 8)
                }
            }
        }
        .navigationTitle("Confirm Send")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(isSending)
    }

    private func sendTransaction() async {
        isSending = true
        _ = await store.sendTransaction()
        isSending = false
    }

    private func abbreviate(_ address: String) -> String {
        guard address.count > 16 else { return address }
        return "\(address.prefix(8))…\(address.suffix(6))"
    }
}

// MARK: - Confirm Row

struct ConfirmRow<Trailing: View>: View {
    let label: String
    @ViewBuilder let trailing: Trailing

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundStyle(Color(.secondaryLabel))
            Spacer()
            trailing
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

#Preview {
    NavigationStack {
        SendConfirmView()
            .environmentObject(WalletStore())
    }
}
