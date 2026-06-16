import SwiftUI

// MARK: - ShadowTheme

/// A named gradient theme used by the shadow layer.
/// Free tier: only .warmGray is available.
struct ShadowTheme: Identifiable, Hashable, Codable, CaseIterable {
    let id: String
    let name: String
    let colors: [CodableColor]
    let isPro: Bool

    static let allCases: [ShadowTheme] = [
        .warmGray,
        .sunset,
        .ocean,
        .forest,
        .midnight,
        .aurora,
        .fire,
        .ice,
        .sepia,
        .monochrome,
        .neon,
        .cosmic,
    ]

    static let warmGray = ShadowTheme(
        id: "warmGray",
        name: "Warm Gray",
        colors: [CodableColor(red: 0.5, green: 0.45, blue: 0.4, alpha: 0.0),
                 CodableColor(red: 0.3, green: 0.28, blue: 0.25, alpha: 0.25)],
        isPro: false
    )

    static let sunset = ShadowTheme(
        id: "sunset",
        name: "Sunset",
        colors: [CodableColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 0.0),
                 CodableColor(red: 1.0, green: 0.3, blue: 0.5, alpha: 0.3)],
        isPro: true
    )

    static let ocean = ShadowTheme(
        id: "ocean",
        name: "Ocean",
        colors: [CodableColor(red: 0.0, green: 0.6, blue: 0.7, alpha: 0.0),
                 CodableColor(red: 0.0, green: 0.2, blue: 0.5, alpha: 0.35)],
        isPro: true
    )

    static let forest = ShadowTheme(
        id: "forest",
        name: "Forest",
        colors: [CodableColor(red: 0.2, green: 0.5, blue: 0.2, alpha: 0.0),
                 CodableColor(red: 0.0, green: 0.35, blue: 0.1, alpha: 0.35)],
        isPro: true
    )

    static let midnight = ShadowTheme(
        id: "midnight",
        name: "Midnight",
        colors: [CodableColor(red: 0.1, green: 0.1, blue: 0.25, alpha: 0.0),
                 CodableColor(red: 0.0, green: 0.0, blue: 0.1, alpha: 0.4)],
        isPro: true
    )

    static let aurora = ShadowTheme(
        id: "aurora",
        name: "Aurora",
        colors: [CodableColor(red: 0.4, green: 0.1, blue: 0.8, alpha: 0.0),
                 CodableColor(red: 0.0, green: 0.8, blue: 0.4, alpha: 0.3)],
        isPro: true
    )

    static let fire = ShadowTheme(
        id: "fire",
        name: "Fire",
        colors: [CodableColor(red: 0.8, green: 0.1, blue: 0.0, alpha: 0.0),
                 CodableColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 0.3)],
        isPro: true
    )

    static let ice = ShadowTheme(
        id: "ice",
        name: "Ice",
        colors: [CodableColor(red: 0.9, green: 0.95, blue: 1.0, alpha: 0.0),
                 CodableColor(red: 0.6, green: 0.8, blue: 1.0, alpha: 0.3)],
        isPro: true
    )

    static let sepia = ShadowTheme(
        id: "sepia",
        name: "Sepia",
        colors: [CodableColor(red: 0.7, green: 0.55, blue: 0.35, alpha: 0.0),
                 CodableColor(red: 0.5, green: 0.35, blue: 0.15, alpha: 0.3)],
        isPro: true
    )

    static let monochrome = ShadowTheme(
        id: "monochrome",
        name: "Monochrome",
        colors: [CodableColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0),
                 CodableColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.35)],
        isPro: true
    )

    static let neon = ShadowTheme(
        id: "neon",
        name: "Neon",
        colors: [CodableColor(red: 1.0, green: 0.2, blue: 0.6, alpha: 0.0),
                 CodableColor(red: 0.6, green: 0.1, blue: 1.0, alpha: 0.3)],
        isPro: true
    )

    static let cosmic = ShadowTheme(
        id: "cosmic",
        name: "Cosmic",
        colors: [CodableColor(red: 0.05, green: 0.0, blue: 0.1, alpha: 0.0),
                 CodableColor(red: 0.0, green: 0.0, blue: 0.05, alpha: 0.45)],
        isPro: true
    )

    var gradientColors: [Color] {
        colors.map { $0.color }
    }

    /// Available themes for the current unlock state.
    static func available(isPro: Bool) -> [ShadowTheme] {
        allCases.filter { !$0.isPro || isPro }
    }
}

// MARK: - CodableColor

/// A color that can be serialised to/from JSON for StoreKit receipts or iCloud.
struct CodableColor: Hashable, Codable {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double

    var color: Color {
        Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}
