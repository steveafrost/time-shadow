import Foundation
import UserNotifications

// MARK: - NotificationService

/// Schedules and cancels the local completion notification used when the app is backgrounded.
@MainActor
final class NotificationService: NSObject, ObservableObject {
    static let shared = NotificationService()

    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined

    private let center = UNUserNotificationCenter.current()
    private let timerNotificationID = "time-shadow.timer-complete"

    private override init() {
        super.init()
        center.delegate = self
        Task { await refreshAuthorizationStatus() }
    }

    // MARK: - Authorization

    @discardableResult
    func requestAuthorizationIfNeeded() async -> Bool {
        await refreshAuthorizationStatus()

        switch authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined:
            do {
                let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
                await refreshAuthorizationStatus()
                return granted
            } catch {
                await refreshAuthorizationStatus()
                return false
            }
        case .denied:
            return false
        @unknown default:
            return false
        }
    }

    func refreshAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }

    // MARK: - Timer Notification

    func scheduleTimerCompletion(after interval: TimeInterval, themeName: String, silent: Bool) async {
        guard interval > 1 else { return }
        guard await requestAuthorizationIfNeeded() else { return }

        cancelTimerCompletion()

        let content = UNMutableNotificationContent()
        content.title = "Time Shadow"
        content.body = "Your \(themeName.lowercased()) shadow has reached the edge."
        content.categoryIdentifier = "TIMER_COMPLETE"
        if !silent {
            content.sound = .default
        }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(interval, 1), repeats: false)
        let request = UNNotificationRequest(identifier: timerNotificationID, content: content, trigger: trigger)

        do {
            try await center.add(request)
        } catch {
            print("[NotificationService] Failed to schedule completion notification: \(error)")
        }
    }

    func cancelTimerCompletion() {
        center.removePendingNotificationRequests(withIdentifiers: [timerNotificationID])
    }
}

extension NotificationService: UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}
