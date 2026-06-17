import SwiftUI
import UIKit

// MARK: - ContentView

/// Root navigation for the app.
/// Shows TimerSetupView by default; navigates to ActiveTimerView when timer starts.
struct ContentView: View {
    @EnvironmentObject private var timerEngine: TimerEngine
    @EnvironmentObject private var proUnlock: ProUnlockManager
    @EnvironmentObject private var analytics: AnalyticsService
    @EnvironmentObject private var appSettings: AppSettings

    @State private var showActiveTimer = false
    @State private var selectedTheme: ShadowTheme = .warmGray

    var body: some View {
        ZStack {
            if showActiveTimer {
                ActiveTimerView(theme: $selectedTheme, onDismiss: {
                    endAmbientSession()
                    showActiveTimer = false
                })
                .transition(.opacity)
                .zIndex(1)
            } else {
                TimerSetupView(selectedTheme: $selectedTheme, onStart: { duration in
                    startAmbientSession(duration: duration)
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showActiveTimer = true
                    }
                })
                .transition(.opacity)
            }
        }
        .animation(.default, value: showActiveTimer)
    }

    // MARK: - Timer Lifecycle

    private func startAmbientSession(duration: TimeInterval) {
        timerEngine.start(duration: duration)
        WidgetDataProvider.shared.start(duration: duration, themeID: selectedTheme.id)

        if appSettings.keepScreenAwakeEnabled {
            UIApplication.shared.isIdleTimerDisabled = true
        }

        if appSettings.liveActivitiesEnabled {
            LiveActivityManager.shared.startActivity(duration: duration, themeID: selectedTheme.id)
        }

        if appSettings.completionNotificationsEnabled {
            Task {
                await NotificationService.shared.scheduleTimerCompletion(
                    after: duration,
                    themeName: selectedTheme.name,
                    silent: appSettings.completionFeedbackIsSilent(isPro: proUnlock.isPro)
                )
            }
        }
    }

    private func endAmbientSession() {
        UIApplication.shared.isIdleTimerDisabled = false
        NotificationService.shared.cancelTimerCompletion()
        WidgetDataProvider.shared.markInactive()
        LiveActivityManager.shared.cancelActivity()
        HapticService.shared.stopHaptic()
    }
}
