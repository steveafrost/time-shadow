import Foundation
import AppIntents
import UIKit

// MARK: - StartTimerIntent

/// AppIntent that starts a focus timer with a specified duration and optional theme.
@available(iOS 16.0, *)
struct StartTimerIntent: AppIntent {
    static let title: LocalizedStringResource = "Start Focus Timer"

    static let description: LocalizedStringResource = "Starts a Time Shadow focus timer with the specified duration and theme."

    @Parameter(title: "Duration (minutes)", description: "How long the timer should run in minutes.", default: 25)
    var duration: Int

    @Parameter(title: "Theme", description: "Optional theme identifier (e.g. 'warmGray', 'sunset', 'ocean').")
    var theme: String?

    static var parameterSummary: some ParameterSummary {
        Summary("Start a \(\.$duration) minute focus timer\(\.$theme)")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<IntentDuration> {
        // Validate duration (minimum 1 minute, max 480 minutes / 8 hours)
        let clampedMinutes = max(1, min(duration, 480))
        let durationSeconds = TimeInterval(clampedMinutes * 60)

        // Resolve timer engine from the app's state
        let engine = TimerEngine.shared

        // Start the timer
        engine.start(duration: durationSeconds)

        // Update widget data with the current state
        WidgetDataProvider.shared.update(
            progress: 0.0,
            remaining: durationSeconds,
            themeID: theme ?? WidgetDataProvider.shared.currentThemeID
        )

        // Reload widget timelines so they reflect the new state
        await WidgetDataProvider.shared.reloadWidgets()

        return .result(value: IntentDuration(durationSeconds))
    }
}

// MARK: - IntentDuration

struct IntentDuration: Equatable, Hashable, Codable {
    let totalSeconds: TimeInterval

    init(_ seconds: TimeInterval) {
        self.totalSeconds = seconds
    }

    var formatted: String {
        let mins = Int(totalSeconds) / 60
        if mins >= 60 {
            return "\(mins / 60)h \(mins % 60)m"
        }
        return "\(mins) min"
    }
}
