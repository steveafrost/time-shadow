import Foundation

// MARK: - WidgetDataProvider

/// Provides data to the Lock Screen widget via UserDefaults (shared app group).
/// The widget reads progress from here; the app writes to it.
class WidgetDataProvider {
    static let shared = WidgetDataProvider()

    private let suiteName = "group.com.nousresearch.timeshadow"
    private let progressKey = "widget_timer_progress"
    private let remainingKey = "widget_timer_remaining"
    private let isActiveKey = "widget_timer_active"
    private let themeIDKey = "widget_timer_theme"

    private var defaults: UserDefaults? {
        UserDefaults(suiteName: suiteName)
    }

    private init() {}

    // MARK: - Write

    func update(progress: Double, remaining: TimeInterval, themeID: String) {
        defaults?.set(progress, forKey: progressKey)
        defaults?.set(remaining, forKey: remainingKey)
        defaults?.set(true, forKey: isActiveKey)
        defaults?.set(themeID, forKey: themeIDKey)
    }

    func markInactive() {
        defaults?.set(false, forKey: isActiveKey)
        defaults?.set(0.0, forKey: progressKey)
        defaults?.set(0.0, forKey: remainingKey)
    }

    // MARK: - Read (used by widget)

    var currentProgress: Double {
        defaults?.double(forKey: progressKey) ?? 0.0
    }

    var currentRemaining: TimeInterval {
        defaults?.double(forKey: remainingKey) ?? 0.0
    }

    var isTimerActive: Bool {
        defaults?.bool(forKey: isActiveKey) ?? false
    }

    var currentThemeID: String {
        defaults?.string(forKey: themeIDKey) ?? "warmGray"
    }
}
