import Foundation
import AppIntents

// MARK: - TimeShadowShortcuts

/// Provides Siri Shortcuts for TimeShadow.
@available(iOS 16.0, *)
struct TimeShadowShortcuts: AppShortcutsProvider {
    @AppShortcutsBuilder
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartTimerIntent(),
            phrases: [
                "Start a \(.default) minute focus with \(.applicationName)",
                "Start a \(\.$duration) minute focus with \(.applicationName)",
                "Begin a focus timer on \(.applicationName)",
                "Start my timer on \(.applicationName)",
            ],
            shortTitle: "Start Focus Timer",
            systemImageName: "timer"
        )
    }
}
