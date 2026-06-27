import Foundation
import BitcoinKit
import BitcoinCore
import HdWalletKit

enum BitcoinServiceError: LocalizedError {
    case kitNotInitialized
    case invalidMnemonic
    case sendFailed(String)
    case invalidAddress(String)

    var errorDescription: String? {
        switch self {
        case .kitNotInitialized: return "Wallet not initialized"
        case .invalidMnemonic: return "Invalid recovery phrase — could not derive seed"
        case .sendFailed(let msg): return "Send failed: \(msg)"
        case .invalidAddress(let addr): return "Invalid address: \(addr)"
        }
    }
}

final class BitcoinService: NSObject {
    private var kit: BitcoinKit.Kit?
    private weak var store: WalletStore?

    // MARK: - Wallet Lifecycle

    func createWallet(words: [String], store: WalletStore) throws {
        self.store = store
        kit?.stop()
        kit = nil

        guard let seed = Mnemonic.seed(mnemonic: words) else {
            throw BitcoinServiceError.invalidMnemonic
        }

        kit = try BitcoinKit.Kit(
            seed: seed,
            purpose: .bip84,
            walletId: "ewallet-main",
            syncMode: .api,
            networkType: .mainNet,
            confirmationsThreshold: 1,
            logger: nil
        )
        kit?.delegate = self
        kit?.start()
    }

    func restoreWallet(words: [String], store: WalletStore) throws {
        self.store = store
        kit?.stop()
        kit = nil

        guard let seed = Mnemonic.seed(mnemonic: words) else {
            throw BitcoinServiceError.invalidMnemonic
        }

        kit = try BitcoinKit.Kit(
            seed: seed,
            purpose: .bip84,
            walletId: "ewallet-main",
            syncMode: .api,
            networkType: .mainNet,
            confirmationsThreshold: 1,
            logger: nil
        )
        kit?.delegate = self
        kit?.start()
    }

    func destroyWallet() {
        let kitToStop = kit
        kit = nil
        kitToStop?.stop()
        // Delay clear to let BitcoinCore finish any in-flight SQLite writes
        // before deleting the database file underneath active connections.
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 1.5) {
            try? BitcoinKit.Kit.clear(exceptFor: [])
        }
    }

    // MARK: - Manual Refresh

    func refresh() {
        kit?.stop()
        kit?.start()
    }

    // MARK: - Reads

    var receiveAddress: String { kit?.receiveAddress() ?? "" }
    var balance: BalanceInfo? { kit?.balance }

    func fetchTransactions() -> [TransactionInfo] {
        return kit?.transactions(fromUid: nil, type: nil, descending: true, limit: 100) ?? []
    }

    // MARK: - Fee Estimation

    func estimatedFee(to address: String, sats: Int, feeRate: Int) -> Int {
        guard let kit = kit else { return 0 }
        let params = SendParameters(address: address, value: sats, feeRate: feeRate, sortType: .bip69)
        return (try? kit.sendInfo(params: params).fee) ?? 0
    }

    // MARK: - Send

    func validateAddress(_ address: String) throws {
        guard let kit = kit else { throw BitcoinServiceError.kitNotInitialized }
        try kit.validate(address: address)
    }

    func send(to address: String, sats: Int, feeRate: Int) throws {
        guard let kit = kit else { throw BitcoinServiceError.kitNotInitialized }
        let params = SendParameters(address: address, value: sats, feeRate: feeRate, sortType: .bip69)
        _ = try kit.send(params: params)
    }

    // MARK: - Mnemonic Helpers (static, no kit needed)

    static func generateMnemonic() throws -> [String] {
        return try Mnemonic.generate(wordCount: .twelve, language: .english)
    }

    static func validateMnemonic(_ words: [String]) throws {
        try Mnemonic.validate(words: words)
    }
}

// MARK: - BitcoinCoreDelegate

extension BitcoinService: BitcoinCoreDelegate {

    func balanceUpdated(balance: BalanceInfo) {
        guard let kit = kit else { return }
        Task { @MainActor [weak self] in
            self?.store?.balance = (
                spendable: kit.balance.spendable,
                unspendable: kit.balance.unspendable
            )
            self?.store?.receiveAddress = kit.receiveAddress()
        }
    }

    func transactionsUpdated(inserted: [TransactionInfo], updated: [TransactionInfo]) {
        let txs = fetchTransactions()
        Task { @MainActor [weak self] in
            self?.store?.transactions = txs
        }
    }

    func transactionsDeleted(hashes: [String]) {
        let txs = fetchTransactions()
        Task { @MainActor [weak self] in
            self?.store?.transactions = txs
        }
    }

    func kitStateUpdated(state: BitcoinCore.KitState) {
        Task { @MainActor [weak self] in
            self?.store?.syncState = state
        }
    }

    func lastBlockInfoUpdated(lastBlockInfo: BlockInfo) { }
}
