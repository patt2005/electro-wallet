import SwiftUI

/// Two-step PIN setup: enter new PIN → confirm PIN
struct PINSetupFlow: View {
    @EnvironmentObject var lockService: LockService
    @Environment(\.dismiss) var dismiss

    @State private var step: Step = .enter
    @State private var firstPIN: String = ""

    enum Step { case enter, confirm }

    var body: some View {
        switch step {
        case .enter:
            PINStepView(title: "Set PIN", subtitle: "Choose a 6-digit PIN") { pin in
                firstPIN = pin
                step = .confirm
                return true
            } onCancel: {
                dismiss()
            }
        case .confirm:
            PINStepView(title: "Confirm PIN", subtitle: "Re-enter your PIN to confirm") { pin in
                if pin == firstPIN {
                    lockService.savePIN(pin)
                    dismiss()
                } else {
                    // Return nil to trigger shake in PINStepView
                    return false
                }
                return true
            } onCancel: {
                step = .enter
                firstPIN = ""
            }
        }
    }
}

struct PINStepView: View {
    let title: String
    let subtitle: String
    /// Return true if PIN accepted, false to shake and reset
    let onComplete: (String) -> Bool
    let onCancel: () -> Void

    @State private var pin: String = ""
    @State private var shake = false
    @State private var showError = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Spacer()

                VStack(spacing: 8) {
                    Text(title)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color(.label))
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundStyle(Color(.secondaryLabel))
                }

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

                if showError {
                    Text("PINs don't match, try again")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.btcRed)
                }

                // Numpad
                VStack(spacing: 16) {
                    ForEach([[1,2,3],[4,5,6],[7,8,9]], id: \.self) { row in
                        HStack(spacing: 24) {
                            ForEach(row, id: \.self) { digit in
                                PINButton(label: "\(digit)") { append("\(digit)") }
                            }
                        }
                    }
                    HStack(spacing: 24) {
                        Color.clear.frame(width: 72, height: 72)
                        PINButton(label: "0") { append("0") }
                        PINButton(label: "⌫", isSymbol: true) {
                            if !pin.isEmpty { pin.removeLast() }
                        }
                    }
                }

                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", action: onCancel)
                        .foregroundStyle(Color.btcGreen)
                }
            }
        }
    }

    private func append(_ d: String) {
        guard pin.count < 6 else { return }
        showError = false
        pin += d
        if pin.count == 6 {
            let accepted = onComplete(pin)
            if !accepted {
                showError = true
                pin = ""
                shake = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { shake = false }
            }
        }
    }
}
