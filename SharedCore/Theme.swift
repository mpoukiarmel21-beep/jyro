import SwiftUI

enum JyroTheme {
    static let appBackground = Color(.sRGB, red: 0.055, green: 0.055, blue: 0.10, opacity: 1)
    static let card = Color(.sRGB, red: 0.13, green: 0.125, blue: 0.21, opacity: 1)
    static let cardSoft = Color(.sRGB, red: 0.16, green: 0.15, blue: 0.26, opacity: 1)
    static let accent = Color(.sRGB, red: 0.62, green: 0.52, blue: 1.0, opacity: 1)
    static let gradient = LinearGradient(
        colors: [
            Color(.sRGB, red: 0.42, green: 0.34, blue: 0.96, opacity: 1),
            Color(.sRGB, red: 0.61, green: 0.34, blue: 0.90, opacity: 1),
            Color(.sRGB, red: 0.95, green: 0.46, blue: 0.71, opacity: 1)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}