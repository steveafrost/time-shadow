import Foundation

// MARK: - TimerPreset

/// A named duration preset shown in the picker grid.
struct TimerPreset: Identifiable, Hashable, Codable {
    let id: UUID
    let name: String
    let duration: TimeInterval // seconds
    let isPro: Bool            // free tier only allows 25 min custom; presets here tagged if pro-only

    static let defaultPresets: [TimerPreset] = [
        TimerPreset(id: UUID(), name: "Focus", duration: 25 * 60, isPro: false),
        TimerPreset(id: UUID(), name: "Short", duration: 5 * 60, isPro: false),
        TimerPreset(id: UUID(), name: "Long", duration: 50 * 60, isPro: false),
        TimerPreset(id: UUID(), name: "Deep Focus", duration: 90 * 60, isPro: true),
        TimerPreset(id: UUID(), name: "Nap", duration: 20 * 60, isPro: false),
        TimerPreset(id: UUID(), name: "Break", duration: 15 * 60, isPro: false),
        TimerPreset(id: UUID(), name: "Work Block", duration: 4 * 3600, isPro: true),
        TimerPreset(id: UUID(), name: "Custom", duration: 25 * 60, isPro: false), // fallback
    ]

    static let freeMaxDuration: TimeInterval = 25 * 60 // free tier max

    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }

    var formattedShort: String {
        let minutes = Int(duration) / 60
        return "\(minutes) min"
    }
}
