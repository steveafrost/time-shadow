import Foundation

// MARK: - AppSettings

/// User-configurable behavior for the timer experience.
/// Stored in UserDefaults so preferences survive TestFlight installs and app relaunches.
@MainActor
final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @Published var completionNotificationsEnabled: Bool {
        didSet { defaults.set(completionNotificationsEnabled, forKey: Keys.completionNotificationsEnabled) }
    }

    @Published var zenModeEnabled: Bool {
        didSet { defaults.set(zenModeEnabled, forKey: Keys.zenModeEnabled) }
    }

    @Published var sunriseHapticsEnabled: Bool {
        didSet { defaults.set(sunriseHapticsEnabled, forKey: Keys.sunriseHapticsEnabled) }
    }

    @Published var liveActivitiesEnabled: Bool {
        didSet { defaults.set(liveActivitiesEnabled, forKey: Keys.liveActivitiesEnabled) }
    }

    @Published var keepScreenAwakeEnabled: Bool {
        didSet { defaults.set(keepScreenAwakeEnabled, forKey: Keys.keepScreenAwakeEnabled) }
    }

    private let defaults: UserDefaults

    private enum Keys {
        static let completionNotificationsEnabled = "settings_completion_notifications_enabled"
        static let zenModeEnabled = "settings_zen_mode_enabled"
        static let sunriseHapticsEnabled = "settings_sunrise_haptics_enabled"
        static let liveActivitiesEnabled = "settings_live_activities_enabled"
        static let keepScreenAwakeEnabled = "settings_keep_screen_awake_enabled"
    }

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        completionNotificationsEnabled = defaults.object(forKey: Keys.completionNotificationsEnabled) as? Bool ?? true
        zenModeEnabled = defaults.object(forKey: Keys.zenModeEnabled) as? Bool ?? false
        sunriseHapticsEnabled = defaults.object(forKey: Keys.sunriseHapticsEnabled) as? Bool ?? true
        liveActivitiesEnabled = defaults.object(forKey: Keys.liveActivitiesEnabled) as? Bool ?? true
        keepScreenAwakeEnabled = defaults.object(forKey: Keys.keepScreenAwakeEnabled) as? Bool ?? true
    }

    func completionFeedbackIsSilent(isPro: Bool) -> Bool {
        isPro && zenModeEnabled
    }
}
