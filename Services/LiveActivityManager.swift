import Foundation
import ActivityKit

// MARK: - LiveActivityManager

/// Manages the Live Activity on the Dynamic Island.
/// Shows a shrinking "shadow bar" and a relative time phrase.
/// Only active on devices and iOS versions that support ActivityKit.
class LiveActivityManager {
    static let shared = LiveActivityManager()

    private var currentActivity: Activity<TimerWidgetAttributes>?

    private init() {}

    // MARK: - Start Activity

    /// Begin a Live Activity for the given timer duration.
    /// Called when the timer starts (Pro feature).
    func startActivity(duration: TimeInterval, themeID: String) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let attributes = TimerWidgetAttributes(timerName: "Time Shadow",
                                                duration: duration,
                                                themeID: themeID)
        let initialContent = ActivityContent(
            state: TimerWidgetAttributes.TimerState(progress: 0.0, remaining: duration),
            staleDate: nil
        )

        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: initialContent,
                pushType: nil
            )
            currentActivity = activity
        } catch {
            // Live Activities not available — silently degrade
            print("[LiveActivityManager] Failed to start activity: \(error)")
        }
    }

    // MARK: - Update

    /// Update the Dynamic Island with current progress.
    func updateActivity(progress: Double, remaining: TimeInterval) {
        guard let activity = currentActivity else { return }

        let contentState = TimerWidgetAttributes.TimerState(progress: progress, remaining: remaining)
        let content = ActivityContent(state: contentState, staleDate: Date().addingTimeInterval(60))

        Task {
            await activity.update(content)
        }
    }

    // MARK: - End

    /// End the Live Activity when the timer completes or is cancelled.
    func endActivity(finalProgress: Double = 1.0) {
        guard let activity = currentActivity else { return }

        let finalState = TimerWidgetAttributes.TimerState(progress: finalProgress, remaining: 0)
        let content = ActivityContent(state: finalState, staleDate: nil)

        Task {
            await activity.end(content, dismissalPolicy: .default)
            currentActivity = nil
        }
    }

    // MARK: - Cancel

    func cancelActivity() {
        guard let activity = currentActivity else { return }
        Task {
            await activity.end(dismissalPolicy: .immediate)
            currentActivity = nil
        }
    }
}

// MARK: - Activity Attributes

struct TimerWidgetAttributes: ActivityAttributes {
    public typealias ContentState = TimerState

    public struct TimerState: Codable, Hashable {
        var progress: Double
        var remaining: TimeInterval
    }

    var timerName: String
    var duration: TimeInterval
    var themeID: String
}
