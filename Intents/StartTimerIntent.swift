import Foundation
import AppIntents
import WidgetKit

// MARK: - StartTimerIntent

/// AppIntent that starts a focus timer with a specified duration and optional theme.
@available(iOS 17.0, *)
struct StartTimerIntent: AppIntent, WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Start Focus Timer"
    static let description: LocalizedStringResource = "Starts a Time Shadow focus timer with the specified duration and theme."
    static var openAppWhenRun = true

    @Parameter(title: "Duration (minutes)", description: "How long the timer should run in minutes.", default: 25)
    var duration: Int

    @Parameter(title: "Theme", description: "Optional theme identifier, like warmGray, sunset, or ocean.")
    var theme: String?

    init() {
        duration = 25
        theme = nil
    }

    init(duration: Int, theme: String? = nil) {
        self.duration = duration
        self.theme = theme
    }

    static var parameterSummary: some ParameterSummary {
        Summary("Start a \(\.$duration) minute focus timer")
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        let clampedMinutes = max(1, min(duration, 480))
        let durationSeconds = TimeInterval(clampedMinutes * 60)
        let themeID = theme ?? WidgetDataProvider.shared.currentThemeID

        #if MAIN_APP
        TimerEngine.shared.start(duration: durationSeconds)
        #endif

        WidgetDataProvider.shared.start(duration: durationSeconds, themeID: themeID)
        WidgetDataProvider.shared.reloadWidgets()

        return .result()
    }
}
