import SwiftUI

// MARK: - ContentView

/// Root navigation for the app.
/// Shows TimerSetupView by default; navigates to ActiveTimerView when timer starts.
struct ContentView: View {
    @EnvironmentObject private var timerEngine: TimerEngine
    @EnvironmentObject private var proUnlock: ProUnlockManager
    @EnvironmentObject private var analytics: AnalyticsService
    @State private var showActiveTimer = false
    @State private var selectedTheme: ShadowTheme = .warmGray

    var body: some View {
        ZStack {
            if showActiveTimer {
                ActiveTimerView(theme: $selectedTheme, onDismiss: {
                    showActiveTimer = false
                })
                .transition(.opacity)
                .zIndex(1)
            } else {
                TimerSetupView(selectedTheme: $selectedTheme, onStart: { duration in
                    timerEngine.start(duration: duration)
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showActiveTimer = true
                    }
                })
                .transition(.opacity)
            }
        }
        .animation(.default, value: showActiveTimer)
    }
}
