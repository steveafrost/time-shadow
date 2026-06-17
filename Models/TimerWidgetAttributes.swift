import ActivityKit
import Foundation

// MARK: - Activity Attributes

/// Shared ActivityKit attributes used by both the app and widget extension.
struct TimerWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var progress: Double
        var remaining: TimeInterval
    }

    var timerName: String
    var duration: TimeInterval
    var themeID: String
}
