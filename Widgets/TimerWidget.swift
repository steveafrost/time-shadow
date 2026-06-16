import WidgetKit
import SwiftUI

// MARK: - TimerWidget

/// Lock Screen widget that shows the current timer progress as a compact gradient bar.
struct TimerWidget: Widget {
    let kind: String = "com.nousresearch.timeshadow.timerwidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TimerWidgetProvider()) { entry in
            TimerWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Timer Progress")
        .description("Shows your active Time Shadow timer.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .systemSmall])
    }
}

// MARK: - Entry

struct TimerWidgetEntry: TimelineEntry {
    let date: Date
    let progress: Double
    let remaining: TimeInterval
    let isActive: Bool
    let themeID: String

    static let placeholder = TimerWidgetEntry(
        date: Date(),
        progress: 0.45,
        remaining: 600,
        isActive: true,
        themeID: "warmGray"
    )
}

// MARK: - Provider

struct TimerWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> TimerWidgetEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (TimerWidgetEntry) -> Void) {
        completion(.placeholder)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TimerWidgetEntry>) -> Void) {
        let data = WidgetDataProvider.shared
        let entry = TimerWidgetEntry(
            date: Date(),
            progress: data.currentProgress,
            remaining: data.currentRemaining,
            isActive: data.isTimerActive,
            themeID: data.currentThemeID
        )
        // Refresh every 15 seconds while active
        let refreshInterval: TimeInterval = data.isTimerActive ? 15 : 300
        let nextUpdate = Date().addingTimeInterval(refreshInterval)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Entry View

struct TimerWidgetEntryView: View {
    var entry: TimerWidgetEntry

    var body: some View {
        Group {
            if entry.isActive {
                switch widgetFamily {
                case .accessoryCircular:
                    circularView
                case .accessoryRectangular:
                    rectangularView
                case .systemSmall:
                    smallView
                default:
                    smallView
                }
            } else {
                inactiveView
            }
        }
    }

    // MARK: - Circular (Lock Screen)

    private var circularView: some View {
        ZStack {
            // Circular progress ring
            Circle()
                .stroke(Color.secondary.opacity(0.3), lineWidth: 3)

            Circle()
                .trim(from: 0, to: entry.progress)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: themeColors),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            Image(systemName: "moon.fill")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(4)
    }

    // MARK: - Rectangular (Lock Screen)

    private var rectangularView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Time Shadow", systemImage: "moon.fill")
                .font(.caption2)
                .foregroundColor(.secondary)

            // Gradient progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.secondary.opacity(0.3))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: themeColors),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * entry.progress, height: 6)
                }
            }
            .frame(height: 6)

            Text(timeRemainingPhrase)
                .font(.caption)
                .foregroundColor(.primary)
        }
    }

    // MARK: - Small (Home Screen)

    private var smallView: some View {
        VStack(spacing: 8) {
            Image(systemName: "moon.fill")
                .font(.title2)
                .foregroundColor(.secondary)

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.secondary.opacity(0.2))
                    .frame(height: 8)

                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: themeColors),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 60 * entry.progress, height: 8)
            }
            .frame(width: 60)

            Text(timeRemainingPhrase)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Inactive

    private var inactiveView: some View {
        VStack(spacing: 4) {
            Image(systemName: "moon")
                .font(.title3)
                .foregroundColor(.secondary)
            Text("No Timer")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Helpers

    private var themeColors: [Color] {
        let defaultColors: [Color] = [.gray, .black.opacity(0.4)]
        guard let theme = ShadowTheme.allCases.first(where: { $0.id == entry.themeID }) else {
            return defaultColors
        }
        return theme.gradientColors
    }

    private var timeRemainingPhrase: String {
        let mins = Int(entry.remaining) / 60
        if mins > 60 {
            return "\(mins / 60)h \(mins % 60)m left"
        }
        return "\(mins) min left"
    }
}
