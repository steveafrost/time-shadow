import WidgetKit
import SwiftUI
import AppIntents

// MARK: - TimerWidget

/// Widget that shows timer progress and provides a Start Focus button.
struct TimerWidget: Widget {
    let kind: String = "com.nousresearch.timeshadow.timerwidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: StartTimerIntent.self,
            provider: TimerWidgetProvider()
        ) { entry in
            TimerWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Timer Progress")
        .description("Shows your active Time Shadow timer with Start Focus button.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .systemSmall, .systemMedium, .systemLarge])
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

    static let inactive = TimerWidgetEntry(
        date: Date(),
        progress: 0.0,
        remaining: 0,
        isActive: false,
        themeID: "warmGray"
    )
}

// MARK: - Provider

struct TimerWidgetProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> TimerWidgetEntry {
        .placeholder
    }

    func snapshot(for configuration: StartTimerIntent, in context: Context) async -> TimerWidgetEntry {
        let data = WidgetDataProvider.shared
        return TimerWidgetEntry(
            date: Date(),
            progress: data.currentProgress,
            remaining: data.currentRemaining,
            isActive: data.isTimerActive,
            themeID: data.currentThemeID
        )
    }

    func timeline(for configuration: StartTimerIntent, in context: Context) async -> Timeline<TimerWidgetEntry> {
        let data = WidgetDataProvider.shared
        let entry = TimerWidgetEntry(
            date: Date(),
            progress: data.currentProgress,
            remaining: data.currentRemaining,
            isActive: data.isTimerActive,
            themeID: data.currentThemeID
        )
        // Refresh every 15 seconds while active, 300 seconds otherwise
        let refreshInterval: TimeInterval = data.isTimerActive ? 15 : 300
        let nextUpdate = Date().addingTimeInterval(refreshInterval)
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }
}

// MARK: - Entry View

struct TimerWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily
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
                case .systemMedium:
                    mediumActiveView
                case .systemLarge:
                    largeActiveView
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

    // MARK: - Medium Active

    private var mediumActiveView: some View {
        HStack(spacing: 12) {
            // Timer progress
            VStack(alignment: .leading, spacing: 6) {
                Label("Time Shadow", systemImage: "moon.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)

                GeometryReader { geo in
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
                            .frame(width: geo.size.width * entry.progress, height: 8)
                    }
                }
                .frame(height: 8)

                Text(timeRemainingPhrase)
                    .font(.caption)
                    .foregroundColor(.primary)
            }

            Spacer()

            // Completion percentage
            VStack {
                Text("\(Int(entry.progress * 100))%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Text("complete")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }

    // MARK: - Large Active

    private var largeActiveView: some View {
        VStack(spacing: 16) {
            Spacer()

            // Circular progress
            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 8)

                Circle()
                    .trim(from: 0, to: entry.progress)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: themeColors),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 4) {
                    Text("\(Int(entry.progress * 100))%")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Text(timeRemainingPhrase)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 120, height: 120)

            // Progress bar
            GeometryReader { geo in
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
                        .frame(width: geo.size.width * entry.progress, height: 8)
                }
            }
            .frame(height: 8)
            .padding(.horizontal, 32)

            Spacer()
        }
        .padding()
    }

    // MARK: - Inactive

    private var inactiveView: some View {
        VStack(spacing: 12) {
            Image(systemName: "moon")
                .font(.title)
                .foregroundColor(.secondary)
            Text("No Timer")
                .font(.headline)
                .foregroundColor(.secondary)

            if widgetFamily == .systemMedium || widgetFamily == .systemLarge {
                Button(intent: StartTimerIntent(duration: 25)) {
                    Label("Start Focus", systemImage: "play.fill")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: themeColors),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .cornerRadius(12)
                        )
                        .foregroundColor(.white)
                }
                .buttonStyle(.plain)
            } else {
                // Small widget hint
                Text("Tap to start")
                    .font(.caption2)
                    .foregroundColor(.secondary.opacity(0.7))
            }
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
