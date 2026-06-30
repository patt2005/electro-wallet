import SwiftUI
import BitcoinCore

struct HomeTabView: View {
    @EnvironmentObject var store: WalletStore
    @Binding var selectedTab: DashboardView.Tab
    @State private var showBalance = true

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Top bar
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("My Wallet")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Color.textPrimary)

                        HStack(spacing: 6) {
                            Circle()
                                .fill(store.isSynced ? Color.btcGreen : Color.btcOrange)
                                .frame(width: 7, height: 7)
                            Text(store.syncStatusText)
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundStyle(Color(red: 102/255, green: 117/255, blue: 107/255))
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 20)

                // Balance Card
                BalanceCard(showBalance: $showBalance)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)

                // Quick Actions
                QuickActionsRow(selectedTab: $selectedTab)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)

                // Recent Transactions
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Recent")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(Color.textPrimary)

                        Spacer()

                        Button {
                            selectedTab = .history
                        } label: {
                            Text("See all →")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(Color.btcGreen)
                        }
                    }

                    if store.transactions.isEmpty {
                        EmptyTransactionsView()
                    } else {
                        ForEach(store.transactions.prefix(3), id: \.transactionHash) { tx in
                            TransactionRow(tx: tx)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
        .refreshable {
            store.bitcoinService.refresh()
        }
        .safeAreaInset(edge: .top) { Color.clear.frame(height: 0) }
    }
}

// MARK: - Balance Card

struct BalanceCard: View {
    @EnvironmentObject var store: WalletStore
    @Binding var showBalance: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("TOTAL BALANCE")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(Color.white.opacity(0.66))
                    .tracking(1.5)

                Spacer()

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showBalance.toggle()
                    }
                } label: {
                    Image(systemName: showBalance ? "eye" : "eye.slash")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.white.opacity(0.70))
                }
            }
            .padding(.bottom, 14)

            // BTC Amount
            HStack(alignment: .lastTextBaseline, spacing: 8) {
                Text(showBalance ? String(format: "%.5f", store.spendableBTC) : "•••••")
                    .font(.system(size: 46, weight: .bold, design: .default))
                    .foregroundStyle(Color.white)
                    .monospacedDigit()

                Text("BTC")
                    .font(.system(size: 16, design: .monospaced))
                    .foregroundStyle(Color.white.opacity(0.70))
            }

            // USD Value
            Text(showBalance
                 ? "≈ \(store.spendableUSD.formatted(.currency(code: "USD")))"
                 : "≈ $ ••••")
                .font(.system(size: 14, design: .monospaced))
                .foregroundStyle(Color.white.opacity(0.60))
                .padding(.top, 4)

            // Divider
            Rectangle()
                .fill(Color.white.opacity(0.16))
                .frame(height: 1)
                .padding(.vertical, 18)

            // BTC Price + 24h
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("BTC PRICE")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(Color.white.opacity(0.66))
                        .tracking(0.8)
                    Text(store.btcUsdRate > 0
                         ? store.btcUsdRate.formatted(.currency(code: "USD").precision(.fractionLength(0)))
                         : "Loading…")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.white)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("24H CHANGE")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(Color.white.opacity(0.66))
                        .tracking(0.8)
                    Text("+2.34%")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color(red: 123/255, green: 230/255, blue: 164/255))
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 18/255, green: 145/255, blue: 78/255),
                    Color(red: 10/255, green: 90/255, blue: 48/255)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 26))
        .shadow(
            color: Color(red: 11/255, green: 90/255, blue: 48/255).opacity(0.34),
            radius: 38,
            x: 0,
            y: 16
        )
    }
}

// MARK: - Quick Actions

struct QuickActionsRow: View {
    @EnvironmentObject var store: WalletStore
    @Binding var selectedTab: DashboardView.Tab

    var body: some View {
        HStack(spacing: 10) {
            QuickAction(
                label: "Send",
                icon: "arrow.up",
                iconColor: Color.btcGreen,
                iconBg: Color.btcGreenLight
            ) { store.showSend = true }

            QuickAction(
                label: "Receive",
                icon: "arrow.down",
                iconColor: Color.btcGreen,
                iconBg: Color.btcGreenLight
            ) { selectedTab = .receive }

            QuickAction(
                label: "History",
                icon: "clock.arrow.circlepath",
                iconColor: Color.btcOrange,
                iconBg: Color(red: 251/255, green: 239/255, blue: 217/255)
            ) { selectedTab = .history }
        }
    }
}

struct QuickAction: View {
    let label: String
    let icon: String
    let iconColor: Color
    let iconBg: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(iconBg)
                        .frame(width: 46, height: 46)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(iconColor)
                }
                Text(label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.cardBorder, lineWidth: 1)
            )
        }
    }
}

// MARK: - Transaction Row

struct TransactionRow: View {
    let tx: TransactionInfo

    private var isSent: Bool { tx.type == .outgoing }
    private var amountBTC: Double { Double(abs(tx.amount)) / 100_000_000 }
    private var dateText: String {
        let date = Date(timeIntervalSince1970: Double(tx.timestamp))
        return date.formatted(date: .abbreviated, time: .shortened)
    }

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 13)
                    .fill(isSent ? Color.btcRed.opacity(0.12) : Color.btcGreenLight)
                    .frame(width: 42, height: 42)
                Image(systemName: isSent ? "arrow.up" : "arrow.down")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(isSent ? Color.btcRed : Color.btcGreen)
            }

            // Label + date
            VStack(alignment: .leading, spacing: 3) {
                Text(isSent ? "Sent" : "Received")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.textPrimary)
                Text(tx.blockHeight != nil ? dateText : "Pending")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer()

            // Amount
            VStack(alignment: .trailing, spacing: 3) {
                Text("\(isSent ? "−" : "+")\(String(format: "%.5f", amountBTC)) BTC")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(isSent ? Color.btcRed : Color.btcGreen)
                if tx.blockHeight != nil {
                    Text(dateText)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.textSecondary)
                } else {
                    Text("Unconfirmed")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.btcOrange)
                }
            }
        }
        .padding(.vertical, 13)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.separator)
                .frame(height: 1)
        }
    }
}

// MARK: - Empty State

struct EmptyTransactionsView: View {
    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .strokeBorder(
                        style: StrokeStyle(lineWidth: 1.5, dash: [5, 4])
                    )
                    .foregroundStyle(Color(red: 203/255, green: 212/255, blue: 204/255))
                    .frame(width: 72, height: 72)

                Text("₿")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(Color(red: 194/255, green: 203/255, blue: 196/255))
            }

            Text("No transactions yet")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.textSecondary)
            Text("Send or receive Bitcoin to get started")
                .font(.system(size: 13))
                .foregroundStyle(Color.textMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}
