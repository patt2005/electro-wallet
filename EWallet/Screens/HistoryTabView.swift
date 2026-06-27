import SwiftUI
import BitcoinCore

struct HistoryTabView: View {
    @EnvironmentObject var store: WalletStore
    @State private var filter: TxFilter = .all

    enum TxFilter: String, CaseIterable {
        case all = "All"
        case received = "Received"
        case sent = "Sent"
    }

    private var filtered: [TransactionInfo] {
        switch filter {
        case .all:
            return store.transactions
        case .received:
            return store.transactions.filter { $0.type == .incoming || $0.type == .sentToSelf }
        case .sent:
            return store.transactions.filter { $0.type == .outgoing }
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 16) {
                    Text("Transactions")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color(.label))

                    // Filter chips
                    HStack(spacing: 8) {
                        ForEach(TxFilter.allCases, id: \.self) { f in
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    filter = f
                                }
                            } label: {
                                Text(f.rawValue)
                                    .font(.system(size: 13, weight: filter == f ? .semibold : .regular))
                                    .foregroundStyle(filter == f ? .white : Color(.secondaryLabel))
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 7)
                                    .background(filter == f ? Color.btcGreen : Color(.systemBackground))
                                    .clipShape(Capsule())
                            }
                        }
                        Spacer()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 16)

                // Transaction list
                if filtered.isEmpty {
                    EmptyTransactionsView()
                        .padding(.top, 40)
                } else {
                    VStack(spacing: 0) {
                        ForEach(filtered, id: \.transactionHash) { tx in
                            TransactionRow(tx: tx)
                                .padding(.horizontal, 20)
                        }
                    }
                }
            }
        }
    }
}
