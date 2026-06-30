import SwiftUI

struct PINEntryView: View {
    @EnvironmentObject var lockService: LockService
    @Environment(\.dismiss) var dismiss

    enum Mode { case unlock, setup, confirm(String) }

    let mode: Mode
    @State private var pin: String = ""
    @State private var shake = false
    @State private var errorMsg: String? = nil

    private var title: String {
        switch mode {
        case .unlock:       return "Enter PIN"
        case .setup:        return "Set PIN"
        case .confirm:      return "Confirm PIN"
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Spacer()

                Text(title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color(.label))

                // Dots
                HStack(spacing: 16) {
                    ForEach(0..<6, id: \.self) { i in
                        Circle()
                            .fill(i < pin.count ? Color.btcGreen : Color(.systemGray4))
                            .frame(width: 14, height: 14)
                    }
                }
                .offset(x: shake ? -10 : 0)
                .animation(shake ? .easeInOut(duration: 0.05).repeatCount(5, autoreverses: true) : .default, value: shake)

                if let msg = errorMsg {
                    Text(msg)
                        .font(.system(size: 14))
                        .foregroundStyle(Color.btcRed)
                }

                // Numpad
                VStack(spacing: 16) {
                    ForEach([[1,2,3],[4,5,6],[7,8,9],[0]], id: \.self) { row in
                        HStack(spacing: 24) {
                            ForEach(row, id: \.self) { digit in
                                if digit == 0 {
                                    // Delete on left of 0, 0 in center, blank on right
                                    Color.clear.frame(width: 72, height: 72)
                                    PINButton(label: "0") { appendDigit("0") }
                                    PINButton(label: "⌫", isSymbol: true) { deleteDigit() }
                                } else {
                                    PINButton(label: "\(digit)") { appendDigit("\(digit)") }
                                }
                            }
                        }
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 32)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.btcGreen)
                }
            }
        }
    }

    private func appendDigit(_ d: String) {
        guard pin.count < 6 else { return }
        pin += d
        errorMsg = nil
        if pin.count == 6 { handleComplete() }
    }

    private func deleteDigit() {
        guard !pin.isEmpty else { return }
        pin.removeLast()
    }

    private func handleComplete() {
        switch mode {
        case .unlock:
            if lockService.verifyPIN(pin) {
                lockService.isUnlocked = true
                dismiss()
            } else {
                triggerError("Incorrect PIN")
            }
        case .setup:
            // Dismiss and re-present with confirm mode — handled by parent
            dismiss()
            // Parent should present PINEntryView(mode: .confirm(pin))
        case .confirm(let original):
            if pin == original {
                lockService.savePIN(pin)
                dismiss()
            } else {
                triggerError("PINs don't match")
            }
        }
    }

    private func triggerError(_ msg: String) {
        errorMsg = msg
        pin = ""
        shake = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { shake = false }
    }
}

struct PINButton: View {
    let label: String
    var isSymbol: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(isSymbol ? .system(size: 22) : .system(size: 26, weight: .light))
                .foregroundStyle(Color(.label))
                .frame(width: 72, height: 72)
                .background(Color(.systemBackground))
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
        }
    }
}
