import Foundation
import WidgetKit

// MARK: - WidgetDataProvider

/// Provides data to the Lock Screen widget via UserDefaults (shared app group).
/// The widget reads progress from here; the app writes to it.
final class WidgetDataProvider {
    static let shared = WidgetDataProvider()

    static let appGroupID = "group.com.steveafrost.TimeShadow"
    static let widgetKind = "com.steveafrost.TimeShadow.timerwidget"

    private let suiteName = WidgetDataProvider.appGroupID
    private let progressKey = "widget_timer_progress"
    private let remainingKey = "widget_timer_remaining"
    private let durationKey = "widget_timer_duration"
    private let endDateKey = "widget_timer_end_date"
    private let isActiveKey = "widget_timer_active"
    private let themeIDKey = "widget_timer_theme"

    private var defaults: UserDefaults? {
        UserDefaults(suiteName: suiteName)
    }

    private init() {}

    // MARK: - Write

    func start(duration: TimeInterval, themeID: String) {
        defaults?.set(0.0, forKey: progressKey)
        defaults?.set(duration, forKey: remainingKey)
        defaults?.set(duration, forKey: durationKey)
        defaults?.set(Date().addingTimeInterval(duration), forKey: endDateKey)
        defaults?.set(true, forKey: isActiveKey)
        defaults?.set(themeID, forKey: themeIDKey)
        WidgetCenter.shared.reloadTimelines(ofKind: Self.widgetKind)
    }

    func update(progress: Double, remaining: TimeInterval, themeID: String) {
        defaults?.set(progress, forKey: progressKey)
        defaults?.set(remaining, forKey: remainingKey)
        if currentDuration <= 0 {
            defaults?.set(max(remaining, 1), forKey: durationKey)
        }
        defaults?.set(Date().addingTimeInterval(remaining), forKey: endDateKey)
        defaults?.set(true, forKey: isActiveKey)
        defaults?.set(themeID, forKey: themeIDKey)
        WidgetCenter.shared.reloadTimelines(ofKind: Self.widgetKind)
    }

    func markInactive() {
        defaults?.set(false, forKey: isActiveKey)
        defaults?.set(0.0, forKey: progressKey)
        defaults?.set(0.0, forKey: remainingKey)
        defaults?.set(0.0, forKey: durationKey)
        defaults?.removeObject(forKey: endDateKey)
        WidgetCenter.shared.reloadTimelines(ofKind: Self.widgetKind)
    }

    // MARK: - Read (used by widget)

    var currentProgress: Double {
        guard isTimerActive else { return 0.0 }
        guard currentDuration > 0 else {
            return defaults?.double(forKey: progressKey) ?? 0.0
        }
        return min(max(1 - (currentRemaining / currentDuration), 0), 1)
    }

    var currentRemaining: TimeInterval {
        guard isTimerActive else { return 0.0 }
        if let endDate = defaults?.object(forKey: endDateKey) as? Date {
            return max(endDate.timeIntervalSinceNow, 0)
        }
        return defaults?.double(forKey: remainingKey) ?? 0.0
    }

    var currentDuration: TimeInterval {
        defaults?.double(forKey: durationKey) ?? 0.0
    }

    var isTimerActive: Bool {
        defaults?.bool(forKey: isActiveKey) ?? false
    }

    var currentThemeID: String {
        defaults?.string(forKey: themeIDKey) ?? "warmGray"
    }

    // MARK: - Widget Reloading

    /// Reloads all widget timelines so they pick up the latest timer state.
    func reloadWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}
