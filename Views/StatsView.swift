import SwiftUI
import Charts

// MARK: - StatsView

/// Shows focus time history with Swift Charts.
struct StatsView: View {
    @EnvironmentObject private var analytics: AnalyticsService
    @Environment(\.dismiss) private var dismiss

    @State private var showClearConfirmation = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    // Summary cards
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        statCard(title: "Sessions", value: "\(analytics.totalSessionsCompleted)", icon: "checkmark.circle")
                        statCard(title: "Total Focus", value: formattedMinutes(analytics.totalFocusMinutes), icon: "clock")
                        statCard(title: "Avg Session", value: String(format: "%.0f min", analytics.averageSessionMinutes), icon: "chart.bar")
                    }
                    .padding(.horizontal)

                    // Weekly chart
                    if !analytics.weeklySessions.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Weekly Focus Time")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)

                            weeklyChart
                                .frame(height: 200)
                                .padding(.horizontal)
                        }
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "chart.bar.xaxis")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                            Text("No sessions yet")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("Complete a timer to see your focus stats.")
                                .font(.caption)
                                .foregroundColor(.tertiary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    }

                    // Recent sessions
                    if !analytics.sessions.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Recent")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)

                            ForEach(analytics.sessions.suffix(10).reversed()) { session in
                                HStack {
                                    Circle()
                                        .fill(Color.primary.opacity(0.3))
                                        .frame(width: 8, height: 8)

                                    Text(session.formattedDate)
                                        .font(.caption)
                                        .foregroundColor(.primary)

                                    Spacer()

                                    Text("\(session.focusMinutes) min")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .scrollIndicators(.hidden)
            .navigationTitle("Focus Stats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .destructiveAction) {
                    Button("Clear", role: .destructive) {
                        showClearConfirmation = true
                    }
                    .font(.caption)
                }
            }
            .alert("Clear all stats?", isPresented: $showClearConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Clear", role: .destructive) {
                    analytics.clear()
                }
            } message: {
                Text("This cannot be undone.")
            }
        }
    }

    // MARK: - Stat Card

    private func statCard(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Weekly Chart

    private var weeklyChart: some View {
        Chart {
            let sortedWeeks = analytics.weeklySessions.keys.sorted()
            ForEach(sortedWeeks, id: \.self) { weekStart in
                if let sessions = analytics.weeklySessions[weekStart] {
                    let total = sessions.filter { $0.completedNormally }.reduce(0) { $0 + $1.actualDuration } / 60
                    BarMark(
                        x: .value("Week", weekStart, unit: .weekOfYear),
                        y: .value("Minutes", total)
                    )
                    .foregroundStyle(.primary.opacity(0.7))
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                AxisValueLabel(format: .dateTime.week(.weekOfYear), centered: true)
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisValueLabel()
            }
        }
    }

    private func formattedMinutes(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 {
            return "\(h)h \(mins)m"
        }
        return "\(mins)m"
    }
}
