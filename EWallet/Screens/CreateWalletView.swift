import SwiftUI

struct CreateWalletView: View {
    @EnvironmentObject var store: WalletStore
    @State private var words: [String] = []
    @State private var isGenerating = true
    @State private var showConfirm = false
    @State private var isCreating = false
    @State private var copied = false

    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            if isGenerating {
                ProgressView()
                    .scaleEffect(1.5)
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        // Warning banner
                        HStack(alignment: .top, spacing: 10) {
                            Text("⚠️")
                                .font(.system(size: 18))
                            Text("Write these 12 words down in order. Anyone with this phrase can access your funds.")
                                .font(.system(size: 13))
                                .foregroundStyle(Color.btcOrange)
                                .lineSpacing(4)
                        }
                        .padding(14)
                        .background(Color.btcOrange.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 13)
                                .stroke(Color.btcOrange.opacity(0.3), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 13))

                        // Section label + copy button
                        HStack {
                            Text("Recovery Phrase")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color(.secondaryLabel))
                                .tracking(0.5)
                                .textCase(.uppercase)

                            Spacer()

                            Button {
                                UIPasteboard.general.string = words.joined(separator: " ")
                                withAnimation(.easeInOut(duration: 0.2)) { copied = true }
                                Task {
                                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                                    withAnimation(.easeInOut(duration: 0.2)) { copied = false }
                                }
                            } label: {
                                HStack(spacing: 5) {
                                    Image(systemName: copied ? "checkmark" : "doc.on.doc")
                                        .font(.system(size: 12, weight: .medium))
                                    Text(copied ? "Copied" : "Copy")
                                        .font(.system(size: 12, weight: .medium))
                                }
                                .foregroundStyle(copied ? Color.btcGreen : Color(.secondaryLabel))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(copied ? Color.btcGreen.opacity(0.1) : Color(.systemBackground))
                                .clipShape(Capsule())
                                .animation(.easeInOut(duration: 0.2), value: copied)
                            }
                        }

                        // Seed grid
                        LazyVGrid(columns: columns, spacing: 8) {
                            ForEach(Array(words.enumerated()), id: \.offset) { index, word in
                                HStack(spacing: 7) {
                                    Text("\(index + 1)")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundStyle(Color(.secondaryLabel))
                                        .frame(minWidth: 14, alignment: .leading)
                                    Text(word)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(Color(.label))
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }

                        // Confirm button
                        Button {
                            showConfirm = true
                        } label: {
                            if isCreating {
                                ProgressView()
                                    .tint(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 17)
                            } else {
                                Text("I've Written This Down →")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 17)
                            }
                        }
                        .background(Color.btcGreen)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .disabled(isCreating)

                        Text("Store offline. Never share. Never photograph.")
                            .font(.system(size: 12))
                            .foregroundStyle(Color(.tertiaryLabel))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
        }
        .navigationTitle("New Wallet")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await generateWords()
        }
        .confirmationDialog(
            "Have you saved your seed phrase?",
            isPresented: $showConfirm,
            titleVisibility: .visible
        ) {
            Button("Yes, I've saved it") {
                Task { await createWallet() }
            }
            Button("Not yet", role: .cancel) {}
        } message: {
            Text("You will not be able to recover your funds without these 12 words.")
        }
    }

    private func generateWords() async {
        do {
            let generated = try BitcoinService.generateMnemonic()
            await MainActor.run {
                words = generated
                isGenerating = false
            }
        } catch {
            await MainActor.run {
                store.errorMessage = error.localizedDescription
                isGenerating = false
            }
        }
    }

    private func createWallet() async {
        isCreating = true
        await store.createNewWallet(words: words)
        isCreating = false
    }
}

#Preview {
    NavigationStack {
        CreateWalletView()
            .environmentObject(WalletStore())
    }
}
