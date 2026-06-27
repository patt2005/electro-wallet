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
            Color(.systemGroupedBackground).ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                Text("Enter your 12 or 24-word recovery phrase, separated by spaces.")
                    .font(.system(size: 15))
                    .foregroundStyle(Color(.secondaryLabel))
                    .lineSpacing(5)
                    .padding(.top, 8)

                // Text area
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.systemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(isValid ? Color.btcGreen : Color(.separator), lineWidth: 1.5)
                        )
                        .frame(height: 165)

                    TextEditor(text: $importText)
                        .font(.system(size: 15))
                        .foregroundStyle(Color(.label))
                        .scrollContentBackground(.hidden)
                        .padding(12)
                        .frame(height: 165)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)

                    if importText.isEmpty {
                        Text("word1 word2 word3 …")
                            .font(.system(size: 15))
                            .foregroundStyle(Color(.placeholderText))
                            .padding(.horizontal, 17)
                            .padding(.top, 20)
                            .allowsHitTesting(false)
                    }
                }

                // Word count indicator
                HStack {
                    if wordCount > 0 {
                        Image(systemName: isValid ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                            .foregroundStyle(isValid ? Color.btcGreen : Color.btcOrange)
                            .font(.system(size: 14))
                        Text(isValid ? "\(wordCount) words ✓" : "\(wordCount) words · need 12 or 24")
                            .font(.system(size: 13, weight: isValid ? .medium : .regular))
                            .foregroundStyle(isValid ? Color.btcGreen : Color.btcOrange)
                    } else {
                        Text("Enter recovery phrase")
                            .font(.system(size: 13))
                            .foregroundStyle(Color(.tertiaryLabel))
                    }
                }

                Spacer()

                Button {
                    Task { await importWallet() }
                } label: {
                    if isImporting {
                        ProgressView()
                            .tint(isValid ? .white : Color(.secondaryLabel))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 17)
                    } else {
                        Text("Import Wallet")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(isValid ? .white : Color(.secondaryLabel))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 17)
                    }
                }
                .background(isValid ? Color.btcGreen : Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isValid ? Color.clear : Color(.separator), lineWidth: 1)
                )
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
