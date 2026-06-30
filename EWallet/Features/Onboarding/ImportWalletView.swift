import SwiftUI

struct ImportWalletView: View {
    @EnvironmentObject var store: WalletStore
    @State private var importText = ""
    @State private var isImporting = false

    private var wordCount: Int {
        importText.trimmingCharacters(in: .whitespaces).isEmpty
            ? 0
            : importText.trimmingCharacters(in: .whitespaces).components(separatedBy: .whitespaces).filter { !$0.isEmpty }.count
    }

    private var isValid: Bool { wordCount == 12 || wordCount == 24 }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                Text("Enter your 12 or 24-word recovery phrase, separated by spaces.")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.textSecondary)
                    .lineSpacing(5)
                    .padding(.top, 8)

                // Text area
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(isValid ? Color.btcGreen : Color.cardBorder, lineWidth: 1)
                        )
                        .frame(minHeight: 190)

                    TextEditor(text: $importText)
                        .font(.system(size: 15, design: .monospaced))
                        .foregroundStyle(Color.textPrimary)
                        .scrollContentBackground(.hidden)
                        .padding(14)
                        .frame(minHeight: 190)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)

                    if importText.isEmpty {
                        Text("word1 word2 word3 …")
                            .font(.system(size: 15, design: .monospaced))
                            .foregroundStyle(Color.textMuted)
                            .padding(.horizontal, 19)
                            .padding(.top, 22)
                            .allowsHitTesting(false)
                    }
                }

                // Word count + paste row
                HStack(spacing: 12) {
                    // Word count indicator
                    HStack(spacing: 6) {
                        if wordCount > 0 {
                            Image(systemName: isValid ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                                .foregroundStyle(isValid ? Color.btcGreen : Color.btcOrange)
                                .font(.system(size: 13))
                        }
                        Text(wordCount > 0
                             ? (isValid ? "\(wordCount) / \(wordCount) WORDS ✓" : "\(wordCount) / 12 WORDS")
                             : "0 / 12 WORDS")
                            .font(.system(size: 11, design: .monospaced))
                            .tracking(1)
                            .foregroundStyle(wordCount > 0
                                             ? (isValid ? Color.btcGreen : Color.btcOrange)
                                             : Color.textMuted)
                    }

                    Spacer()

                    // Paste button
                    Button {
                        if let str = UIPasteboard.general.string {
                            importText = str
                        }
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "doc.on.clipboard")
                                .font(.system(size: 12, weight: .medium))
                            Text("Paste")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundStyle(Color.btcGreen)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.btcGreenLight)
                        .clipShape(RoundedRectangle(cornerRadius: 9))
                    }
                }

                // BIP-39 note
                Text("BIP-39 compatible recovery phrases only.")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(Color.textMuted)

                Spacer()

                Button {
                    Task { await importWallet() }
                } label: {
                    if isImporting {
                        ProgressView()
                            .tint(isValid ? .white : Color.textSecondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                    } else {
                        Text("Import Wallet")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(isValid ? .white : Color.textSecondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                    }
                }
                .background(isValid ? Color.btcGreen : Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isValid ? Color.clear : Color.cardBorder, lineWidth: 1)
                )
                .shadow(color: isValid ? Color.btcGreen.opacity(0.32) : Color.clear, radius: 22, x: 0, y: 8)
                .disabled(!isValid || isImporting)
                .animation(.easeInOut(duration: 0.2), value: isValid)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .navigationTitle("Import Wallet")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func importWallet() async {
        isImporting = true
        let words = importText
            .trimmingCharacters(in: .whitespaces)
            .lowercased()
            .components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }
        await store.importWallet(words: words)
        isImporting = false
    }
}
