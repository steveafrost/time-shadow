import Foundation
import Combine

// MARK: - AnalyticsService

/// Tracks focus time history for stats.
/// Persists to UserDefaults as JSON array of TimerSession.
class AnalyticsService: ObservableObject {
    static let shared = AnalyticsService()

    @Published var sessions: [TimerSession] = []

    private let storageKey = "analytics_sessions"
    private let maxSessions = 500

    private init() {
        load()
    }

    // MARK: - Record

    func recordSession(_ session: TimerSession) {
        sessions.append(session)
        // Keep at fixed max to avoid unbounded storage
        if sessions.count > maxSessions {
            sessions = Array(sessions.suffix(maxSessions))
        }
        save()
    }

    // MARK: - Stats

    var totalFocusMinutes: Int {
        sessions.filter { $0.completedNormally }.reduce(0) { $0 + $1.focusMinutes }
    }

    var totalSessionsCompleted: Int {
        sessions.filter { $0.completedNormally }.count
    }

    var averageSessionMinutes: Double {
        let completed = sessions.filter { $0.completedNormally }
        guard !completed.isEmpty else { return 0 }
        let total = completed.reduce(0.0) { $0 + $1.actualDuration }
        return total / Double(completed.count) / 60.0
    }

    /// Sessions grouped by week for charting.
    var weeklySessions: [Date: [TimerSession]] {
        let cal = Calendar.current
        var grouped: [Date: [TimerSession]] = [:]
        for session in sessions {
            guard let weekStart = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: session.startDate)) else { continue }
            grouped[weekStart, default: []].append(session)
        }
        return grouped
    }

    // MARK: - Persistence

    private func save() {
        guard let data = try? JSONEncoder().encode(sessions) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([TimerSession].self, from: data) else {
            sessions = []
            return
        }
        sessions = decoded
    }

    /// Clear all history (user-requested).
    func clear() {
        sessions = []
        save()
    }
}
