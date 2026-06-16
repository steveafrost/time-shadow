import Foundation

// MARK: - TimerSession

/// A completed timer session, persisted for stats/history.
struct TimerSession: Identifiable, Hashable, Codable {
    let id: UUID
    let startDate: Date
    let endDate: Date
    let duration: TimeInterval      // planned duration in seconds
    let actualDuration: TimeInterval // how long it actually ran (may include pauses)
    let themeID: String
    let completedNormally: Bool      // true = natural end, false = cancelled

    init(id: UUID = UUID(),
         startDate: Date,
         endDate: Date,
         duration: TimeInterval,
         actualDuration: TimeInterval,
         themeID: String,
         completedNormally: Bool) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.duration = duration
        self.actualDuration = actualDuration
        self.themeID = themeID
        self.completedNormally = completedNormally
    }

    var focusMinutes: Int {
        Int(actualDuration / 60)
    }

    var formattedDate: String {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df.string(from: startDate)
    }
}
