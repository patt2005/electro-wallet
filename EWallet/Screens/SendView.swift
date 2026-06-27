import SwiftUI

struct SendView: View {
    @EnvironmentObject var store: WalletStore
    @State private var showConfirm = false

    private var amountSats: Int { store.sendAmountSats }
    private var maxBTC: Double { store.spendableBTC }

    private var isAddressValid: Bool { store.sendAddress.count > 20 }
    private var isAmountValid: Bool {
        guard let amt = Double(store.sendAmountBTC) else { return false }
        return amt > 0 && amt <= maxBTC
    }
    private var canReview: Bool { isAddressValid && isAmountValid }

    private var amtUSD: String {
        guard let amt = Double(store.sendAmountBTC) else { return "$0.00" }
        return (amt * store.btcUsdRate).formatted(.currency(code: "USD"))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 18) {
                        // Amount
                        VStack(spacing: 0) {
                            Text("Amount")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(Color(.secondaryLabel))
                                .textCase(.uppercase)
                                .tracking(0.8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom, 10)

                            HStack(alignment: .lastTextBaseline, spacing: 8) {
                                TextField("0.00000", text: $store.sendAmountBTC)
                                    .font(.system(size: 38, weight: .ultraLight))
                                    .foregroundStyle(Color(.label))
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.center)
                                    .monospacedDigit()
                                    .frame(maxWidth: .infinity)

                                Text("BTC")
                                    .font(.system(size: 20, weight: .light))
                                    .foregroundStyle(Color(.secondaryLabel))
                            }

                            Text("≈ \(amtUSD)")
                                .font(.system(size: 14))
                                .foregroundStyle(Color(.secondaryLabel))
                                .padding(.top, 6)

                            if let amt = Double(store.sendAmountBTC), amt > maxBTC {
                                Text("Insufficient balance")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(Color.btcRed)
                                    .padding(.top, 4)
                            }

                            // Max button
                            Button {
                                store.sendAmountBTC = String(format: "%.5f", maxBTC)
                            } label: {
                                Text("MAX")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(Color.btcGreen)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(Color.btcGreen.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                            .padding(.top, 10)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color(.separator).opacity(0.5), lineWidth: 1)
                        )

                        // Recipient Address
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Recipient Address")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color(.secondaryLabel))

                            HStack(spacing: 10) {
                                TextField("Bitcoin address (bc1q…)", text: $store.sendAddress)
                                    .font(.system(size: 13, design: .monospaced))
                                    .foregroundStyle(Color(.label))
                                    .autocorrectionDisabled()
                                    .textInputAutocapitalization(.never)
                                    .lineLimit(2)

                                // Paste button
                                Button {
                                    if let str = UIPasteboard.general.string {
                                        store.sendAddress = str
                                    }
                                } label: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.btcGreen.opacity(0.1))
                                            .frame(width: 32, height: 32)
                                        Image(systemName: "doc.on.clipboard")
                                            .font(.system(size: 14))
                                            .foregroundStyle(Color.btcGreen)
                                    }
                                }
                            }
                            .padding(14)
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(isAddressValid ? Color.btcGreen : Color(.separator), lineWidth: 1.5)
                            )
                            .animation(.easeInOut(duration: 0.2), value: isAddressValid)
                        }

                        // Fee Selector
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Network Fee")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color(.secondaryLabel))

                            VStack(spacing: 8) {
                                ForEach(FeeLevel.allCases) { level in
                                    FeeLevelRow(
                                        level: level,
                                        isSelected: store.sendFeeLevel == level,
                                        estimatedFeeSats: Int64(store.estimateFee(feeLevel: level))
                                    ) {
                                        store.sendFeeLevel = level
                                    }
                                }
                            }
                        }

                        // Review button
                        Button {
                            showConfirm = true
                        } label: {
                            Text("Review →")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(canReview ? .white : Color(.secondaryLabel))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 17)
                                .background(canReview ? Color.btcGreen : Color(.systemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(canReview ? Color.clear : Color(.separator), lineWidth: 1)
                                )
                        }
                        .disabled(!canReview)
                        .animation(.easeInOut(duration: 0.2), value: canReview)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Send Bitcoin")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { store.showSend = false }
                        .foregroundStyle(Color.btcGreen)
                }
            }
            .navigationDestination(isPresented: $showConfirm) {
                SendConfirmView()
            }
        }
    }
}

// MARK: - Fee Level Row

struct FeeLevelRow: View {
    let level: FeeLevel
    let isSelected: Bool
    let estimatedFeeSats: Int64
    let onTap: () -> Void

    private var feeBTC: String {
        String(format: "%.8f", Double(estimatedFeeSats) / 100_000_000)
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                Circle()
                    .fill(isSelected ? Color.btcGreen : Color(.separator))
                    .frame(width: 8, height: 8)

                VStack(alignment: .leading, spacing: 2) {
                    Text(level.rawValue)
                        .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                        .foregroundStyle(isSelected ? Color(.label) : Color(.secondaryLabel))
                    Text(level.estimatedTime)
                        .font(.system(size: 12))
                        .foregroundStyle(Color(.tertiaryLabel))
                }

                Spacer()

                if estimatedFeeSats > 0 {
                    Text("\(feeBTC) BTC")
                        .font(.system(size: 13))
                        .foregroundStyle(Color(.secondaryLabel))
                } else {
                    Text("—")
                        .font(.system(size: 13))
                        .foregroundStyle(Color(.tertiaryLabel))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 13)
                    .fill(isSelected ? Color.btcGreen.opacity(0.05) : Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 13)
                            .stroke(isSelected ? Color.btcGreen : Color(.separator).opacity(0.5), lineWidth: 1.5)
                    )
            )
        }
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}
