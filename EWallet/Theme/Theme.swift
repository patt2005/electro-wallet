import SwiftUI

// MARK: - Design System Colors

extension Color {
    static let btcGreen      = Color(red: 26/255,  green: 143/255, blue: 76/255)
    static let btcGreenDark  = Color(red: 10/255,  green: 90/255,  blue: 48/255)
    static let btcGreenLight = Color(red: 227/255, green: 241/255, blue: 232/255)
    static let btcRed        = Color(red: 207/255, green: 58/255,  blue: 48/255)
    static let btcOrange     = Color(red: 224/255, green: 153/255, blue: 30/255)
    static let appBackground = Color(red: 233/255, green: 237/255, blue: 230/255)
    static let cardSurface   = Color.white
    static let cardBorder    = Color(red: 226/255, green: 232/255, blue: 222/255)
    static let textPrimary   = Color(red: 15/255,  green: 28/255,  blue: 20/255)
    static let textSecondary = Color(red: 92/255,  green: 107/255, blue: 98/255)
    static let textMuted     = Color(red: 150/255, green: 163/255, blue: 154/255)
    static let warningBg     = Color(red: 251/255, green: 240/255, blue: 218/255)
    static let warningBorder = Color(red: 240/255, green: 222/255, blue: 182/255)
    static let warningText   = Color(red: 138/255, green: 99/255,  blue: 20/255)
    static let separator     = Color(red: 15/255,  green: 28/255,  blue: 20/255).opacity(0.07)
    // Legacy aliases kept for any remaining references
    static let btcBlue       = Color(red: 30/255,  green: 144/255, blue: 255/255)
    static let cardBg        = Color.white
}
