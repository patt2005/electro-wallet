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
            Color.appBackground.ignoresSafeArea()

            if isGenerating {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(Color.btcGreen)
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        // Warning banner
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(Color.btcOrange)
                                .padding(.top, 1)

                            Text("Write these 12 words down in order. Anyone with this phrase can access your funds.")
                                .font(.system(size: 13))
                                .foregroundStyle(Color.warningText)
                                .lineSpacing(4)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 14)
                        .background(Color.warningBg)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.warningBorder, lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                        // Section label + copy button
                        HStack {
                            Text("RECOVERY PHRASE")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundStyle(Color(red: 126/255, green: 140/255, blue: 130/255))
                                .tracking(1.2)

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
                                .foregroundStyle(copied ? Color.btcGreen : Color.textSecondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.white)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(Color.cardBorder, lineWidth: 1)
                                )
                                .animation(.easeInOut(duration: 0.2), value: copied)
                            }
                        }

                        // Seed grid
                        LazyVGrid(columns: columns, spacing: 8) {
                            ForEach(Array(words.enumerated()), id: \.offset) { index, word in
                                HStack(spacing: 6) {
                                    Text("\(index + 1)")
                                        .font(.system(size: 10, design: .monospaced))
                                        .foregroundStyle(Color.textMuted)
                                        .frame(minWidth: 14, alignment: .leading)
                                    Text(word)
                                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                                        .foregroundStyle(Color.textPrimary)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.cardBorder, lineWidth: 1)
                                )
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
                                    .frame(height: 56)
                            } else {
                                Text("I've Written This Down →")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                            }
                        }
                        .background(Color.btcGreen)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color.btcGreen.opacity(0.32), radius: 22, x: 0, y: 8)
                        .disabled(isCreating)

                        Text("Store offline. Never share. Never photograph.")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundStyle(Color.textMuted)
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
