import Foundation
import BitcoinKit
import BitcoinCore
import Combine

@MainActor
final class WalletStore: ObservableObject {

    // MARK: - Navigation State
    @Published var isWalletCreated: Bool = false
    @Published var isLoading: Bool = true

    // MARK: - Wallet Data
    @Published var balance: (spendable: Int, unspendable: Int) = (0, 0)
    @Published var receiveAddress: String = ""
    @Published var transactions: [TransactionInfo] = []
    @Published var syncState: BitcoinCore.KitState = .syncingStarted
    @Published var btcUsdRate: Double = 0

    // MARK: - Send Flow (transient, lives here across screen transitions)
    @Published var sendAddress: String = ""
    @Published var sendAmountBTC: String = ""
    @Published var sendFeeLevel: FeeLevel = .standard

    // MARK: - UI State
    @Published var errorMessage: String? = nil
    @Published var showSend: Bool = false
    @Published var showSendSuccess: Bool = false

    // MARK: - Services
    let bitcoinService = BitcoinService()
    let priceService = PriceService()

    // MARK: - Computed

    var spendableBTC: Double { Double(balance.spendable) / 100_000_000.0 }
    var spendableUSD: Double { spendableBTC * btcUsdRate }

    var sendAmountSats: Int {
        Int((Double(sendAmountBTC) ?? 0) * 100_000_000)
    }

    var syncStatusText: String {
        switch syncState {
        case .synced:
            return "Mainnet · Synced"
        case .apiSyncing(let txs):
            return "Syncing (\(txs) txs)"
        case .syncingStarted:
            return "Connecting…"
        case .syncing(let all, let downloaded):
            let pct = all > 0 ? Int(Double(downloaded) / Double(all) * 100) : 0
            return "Syncing \(pct)%"
        case .notSynced(let error):
            return "Error: \(error.localizedDescription)"
        }
    }

    var isSynced: Bool {
        if case .synced = syncState { return true }
        return false
    }

    // MARK: - Init

    init() {
        Task {
            if let words = KeychainStore.load() {
                do {
                    try bitcoinService.restoreWallet(words: words, store: self)
                    priceService.start(store: self)
                    receiveAddress = bitcoinService.receiveAddress
                    isWalletCreated = true
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
            isLoading = false
        }
    }

    // MARK: - Wallet Actions

    func createNewWallet(words: [String]) async {
        do {
            try KeychainStore.save(words: words)
            try bitcoinService.createWallet(words: words, store: self)
            priceService.start(store: self)
            receiveAddress = bitcoinService.receiveAddress
            isWalletCreated = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func importWallet(words: [String]) async {
        do {
            try BitcoinService.validateMnemonic(words)
            try KeychainStore.save(words: words)
            try bitcoinService.restoreWallet(words: words, store: self)
            priceService.start(store: self)
            receiveAddress = bitcoinService.receiveAddress
            isWalletCreated = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func resetWallet() {
        // Clear UI state first so Dashboard tears down before kit stops
        isWalletCreated = false
        balance = (0, 0)
        receiveAddress = ""
        transactions = []
        btcUsdRate = 0
        // Stop services and wipe persisted data
        priceService.stop()
        KeychainStore.delete()
        bitcoinService.destroyWallet()
    }

    // MARK: - Send Actions

    func sendTransaction() async -> Bool {
        do {
            try bitcoinService.validateAddress(sendAddress)
            try bitcoinService.send(
                to: sendAddress,
                sats: sendAmountSats,
                feeRate: sendFeeLevel.feeRate
            )
            // Reset send state
            sendAddress = ""
            sendAmountBTC = ""
            sendFeeLevel = .standard
            showSend = false
            showSendSuccess = true
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func estimateFee(feeLevel: FeeLevel) -> Int {
        guard !sendAddress.isEmpty, sendAmountSats > 0 else { return 0 }
        return bitcoinService.estimatedFee(
            to: sendAddress,
            sats: sendAmountSats,
            feeRate: feeLevel.feeRate
        )
    }
}

// MARK: - FeeLevel

enum FeeLevel: String, CaseIterable, Identifiable {
    case economy = "Economy"
    case standard = "Standard"
    case priority = "Priority"

    var id: String { rawValue }

    var feeRate: Int {
        switch self {
        case .economy: return 1
        case .standard: return 5
        case .priority: return 20
        }
    }

    var estimatedTime: String {
        switch self {
        case .economy: return "~60 min"
        case .standard: return "~30 min"
        case .priority: return "~10 min"
        }
    }
}
