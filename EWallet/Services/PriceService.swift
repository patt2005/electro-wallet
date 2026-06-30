import Foundation

final class PriceService {
    private weak var store: WalletStore?
    private var pollingTask: Task<Void, Never>?

    func start(store: WalletStore) {
        self.store = store
        pollingTask?.cancel()
        pollingTask = Task { [weak self] in
            while !Task.isCancelled {
                await self?.fetchRate()
                try? await Task.sleep(nanoseconds: 60_000_000_000) // 60s
            }
        }
    }

    func stop() {
        pollingTask?.cancel()
        pollingTask = nil
    }

    private func fetchRate() async {
        let urlString = "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd"
        guard let url = URL(string: urlString),
              let (data, _) = try? await URLSession.shared.data(from: url),
              let json = try? JSONDecoder().decode([String: [String: Double]].self, from: data),
              let rate = json["bitcoin"]?["usd"] else { return }

        await MainActor.run { [weak self] in
            self?.store?.btcUsdRate = rate
        }
    }
}
