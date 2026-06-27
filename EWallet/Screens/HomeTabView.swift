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
                            .font(.system(size: 13))
                            .foregroundStyle(Color(.secondaryLabel))

                        HStack(spacing: 6) {
                            Circle()
                                .fill(store.isSynced ? Color.btcGreen : Color.btcOrange)
                                .frame(width: 7, height: 7)
                            Text(store.syncStatusText)
                                .font(.system(size: 12))
                                .foregroundStyle(Color(.secondaryLabel))
                        }
                    }

                    Spacer()

                    Button {
                        // Notification placeholder
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(.separator), lineWidth: 1)
                                )
                                .frame(width: 38, height: 38)

                            Image(systemName: "bell")
                                .font(.system(size: 16))
                                .foregroundStyle(Color(.secondaryLabel))
                        }
                    }
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
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color(.label))

                        Spacer()

                        Button {
                            selectedTab = .history
                        } label: {
                            Text("See all →")
                                .font(.system(size: 14))
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
                Text("Total Balance")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color(.secondaryLabel))
                    .textCase(.uppercase)
                    .tracking(0.7)

                Spacer()

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showBalance.toggle()
                    }
                } label: {
                    Image(systemName: showBalance ? "eye" : "eye.slash")
                        .font(.system(size: 16))
                        .foregroundStyle(Color(.secondaryLabel))
                }
            }
            .padding(.bottom, 8)

            // BTC Amount
            HStack(alignment: .lastTextBaseline, spacing: 8) {
                Text(showBalance ? String(format: "%.5f", store.spendableBTC) : "•••••")
                    .font(.system(size: 42, weight: .ultraLight, design: .default))
                    .foregroundStyle(Color(.label))
                    .monospacedDigit()

                Text("BTC")
                    .font(.system(size: 20, weight: .light))
                    .foregroundStyle(Color(.secondaryLabel))
            }

            // USD Value
            Text(showBalance
                 ? "≈ \(store.spendableUSD.formatted(.currency(code: "USD")))"
                 : "≈ $ ••••")
                .font(.system(size: 15))
                .foregroundStyle(Color(.secondaryLabel))
                .padding(.top, 2)

            Divider()
                .padding(.vertical, 16)

            // BTC Price + 24h
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("BTC Price")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color(.secondaryLabel))
                        .textCase(.uppercase)
                        .tracking(0.6)
                    Text(store.btcUsdRate > 0
                         ? store.btcUsdRate.formatted(.currency(code: "USD").precision(.fractionLength(0)))
                         : "Loading…")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color(.label))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 3) {
                    Text("24h Change")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color(.secondaryLabel))
                        .textCase(.uppercase)
                        .tracking(0.6)
                    Text("+2.34%")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.btcGreen)
                }
            }
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 22)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color(.separator).opacity(0.5), lineWidth: 1)
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
                iconColor: Color.btcBlue,
                iconBg: Color.btcBlue.opacity(0.12)
            ) { store.showSend = true }

            QuickAction(
                label: "Receive",
                icon: "arrow.down",
                iconColor: Color.btcGreen,
                iconBg: Color.btcGreen.opacity(0.12)
            ) { selectedTab = .receive }

            QuickAction(
                label: "History",
                icon: "clock.arrow.circlepath",
                iconColor: Color.btcOrange,
                iconBg: Color.btcOrange.opacity(0.12)
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
                    .foregroundStyle(Color(.label))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(.separator).opacity(0.5), lineWidth: 1)
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
                    .fill(isSent ? Color.btcRed.opacity(0.12) : Color.btcGreen.opacity(0.12))
                    .frame(width: 42, height: 42)
                Image(systemName: isSent ? "arrow.up" : "arrow.down")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(isSent ? Color.btcRed : Color.btcGreen)
            }

            // Label + date
            VStack(alignment: .leading, spacing: 3) {
                Text(isSent ? "Sent" : "Received")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color(.label))
                Text(tx.blockHeight != nil ? dateText : "Pending")
                    .font(.system(size: 12))
                    .foregroundStyle(Color(.secondaryLabel))
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
                        .foregroundStyle(Color(.secondaryLabel))
                } else {
                    Text("Unconfirmed")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.btcOrange)
                }
            }
        }
        .padding(.vertical, 13)
        .overlay(alignment: .bottom) {
            Divider()
        }
    }
}

// MARK: - Empty State

struct EmptyTransactionsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "bitcoinsign.circle")
                .font(.system(size: 40))
                .foregroundStyle(Color(.tertiaryLabel))
            Text("No transactions yet")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color(.secondaryLabel))
            Text("Send or receive Bitcoin to get started")
                .font(.system(size: 13))
                .foregroundStyle(Color(.tertiaryLabel))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}
