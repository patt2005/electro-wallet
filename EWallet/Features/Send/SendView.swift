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
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 18) {
                        // Amount card
                        VStack(spacing: 0) {
                            Text("AMOUNT")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundStyle(Color.textMuted)
                                .tracking(1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom, 12)

                            HStack(alignment: .lastTextBaseline, spacing: 8) {
                                TextField("0.00000", text: $store.sendAmountBTC)
                                    .font(.system(size: 46, weight: .bold))
                                    .foregroundStyle(
                                        store.sendAmountBTC.isEmpty
                                            ? Color.textMuted
                                            : Color.textPrimary
                                    )
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.center)
                                    .monospacedDigit()
                                    .frame(maxWidth: .infinity)

                                Text("BTC")
                                    .font(.system(size: 20, weight: .light))
                                    .foregroundStyle(Color.textSecondary)
                            }

                            Text("≈ \(amtUSD)")
                                .font(.system(size: 14, design: .monospaced))
                                .foregroundStyle(Color.textSecondary)
                                .padding(.top, 6)

                            if let amt = Double(store.sendAmountBTC), amt > maxBTC {
                                Text("Insufficient balance")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(Color.btcRed)
                                    .padding(.top, 4)
                            }

                            // MAX button
                            Button {
                                store.sendAmountBTC = String(format: "%.5f", maxBTC)
                            } label: {
                                Text("MAX")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(Color.btcGreen)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 5)
                                    .background(Color.btcGreenLight)
                                    .clipShape(Capsule())
                            }
                            .padding(.top, 12)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22)
                                .stroke(Color.cardBorder, lineWidth: 1)
                        )
                        .shadow(color: Color.separator, radius: 8, x: 0, y: 2)

                        // Recipient Address
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Recipient Address")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color.textSecondary)

                            HStack(spacing: 10) {
                                TextField("Bitcoin address (bc1q…)", text: $store.sendAddress)
                                    .font(.system(size: 13, design: .monospaced))
                                    .foregroundStyle(Color.textPrimary)
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
                                            .fill(Color.btcGreenLight)
                                            .frame(width: 34, height: 34)
                                        Image(systemName: "doc.on.clipboard")
                                            .font(.system(size: 14))
                                            .foregroundStyle(Color.btcGreen)
                                    }
                                }
                            }
                            .padding(14)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(isAddressValid ? Color.btcGreen : Color.cardBorder, lineWidth: 1)
                            )
                            .animation(.easeInOut(duration: 0.2), value: isAddressValid)
                        }

                        // Fee Selector
                        VStack(alignment: .leading, spacing: 10) {
                            Text("NETWORK FEE")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundStyle(Color.textMuted)
                                .tracking(1)

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
                                .foregroundStyle(canReview ? .white : Color.textSecondary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(canReview ? Color.btcGreen : Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(canReview ? Color.clear : Color.cardBorder, lineWidth: 1)
                                )
                                .shadow(color: canReview ? Color.btcGreen.opacity(0.32) : Color.clear,
                                        radius: 22, x: 0, y: 8)
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
            HStack(spacing: 12) {
                // Radio circle
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.btcGreen : Color.cardBorder, lineWidth: 1.5)
                        .frame(width: 18, height: 18)
                    if isSelected {
                        Circle()
                            .fill(Color.btcGreen)
                            .frame(width: 9, height: 9)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(level.rawValue)
                        .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                        .foregroundStyle(isSelected ? Color.textPrimary : Color.textSecondary)
                    Text(level.estimatedTime)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.textMuted)
                }

                Spacer()

                if estimatedFeeSats > 0 {
                    Text("\(feeBTC) BTC")
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundStyle(Color.textSecondary)
                } else {
                    Text("—")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.textMuted)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color(red: 234/255, green: 246/255, blue: 238/255) : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isSelected ? Color.btcGreen : Color.cardBorder, lineWidth: 1.5)
                    )
            )
        }
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}
