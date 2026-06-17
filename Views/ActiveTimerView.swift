import SwiftUI
import UIKit

// MARK: - ActiveTimerView

/// Full-screen view during an active timer.
/// Wallpaper visible behind a translucent gradient overlay;
/// the shadow creeps across from left to right.
/// No numbers, just ambient awareness.
struct ActiveTimerView: View {
    @EnvironmentObject private var timerEngine: TimerEngine
    @EnvironmentObject private var proUnlock: ProUnlockManager
    @EnvironmentObject private var analytics: AnalyticsService
    @EnvironmentObject private var appSettings: AppSettings

    @Binding var theme: ShadowTheme
    let onDismiss: () -> Void

    @State private var showCompletion = false
    @State private var lastExternalSurfaceUpdate = Date.distantPast

    var body: some View {
        ZStack {
            // Wallpaper (solid background since we can't access user wallpaper)
            Color(.systemBackground)
                .ignoresSafeArea()

            // Shadow overlay that creeps across
            ShadowOverlay(
                progress: timerEngine.progress,
                theme: theme,
                isActive: timerEngine.isRunning
            )
            .ignoresSafeArea()

            // Completion checkmark (subtle)
            if showCompletion {
                CompletionView(session: currentSession) {
                    withAnimation {
                        showCompletion = false
                        timerEngine.cancel()
                        onDismiss()
                    }
                }
                .transition(.opacity)
                .zIndex(2)
            }

            // Pause indicator
            if timerEngine.isPaused {
                pauseIndicator
                    .transition(.opacity)
                    .zIndex(1)
            }

            // Tap zones for pause/dismiss
            VStack {
                Spacer()
                HStack {
                    cancelButton
                        .padding(.leading, 24)

                    Spacer()

                    pauseResumeButton
                        .padding(.trailing, 24)
                }
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            timerEngine.onComplete = handleCompletion
        }
        .onChange(of: timerEngine.progress) { _, newProgress in
            updateExternalSurfaces(progress: newProgress)
        }
        .statusBar(hidden: true)
        .preferredColorScheme(.dark)
    }

    // MARK: - Controls

    private var cancelButton: some View {
        Button {
            withAnimation {
                timerEngine.cancel()
                onDismiss()
            }
        } label: {
            Image(systemName: "xmark")
                .font(.title3)
                .foregroundColor(.secondary)
                .padding(20)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
        }
        .accessibilityLabel("Cancel timer")
        .accessibilityHint("Stops the current Time Shadow timer")
    }

    private var pauseResumeButton: some View {
        Button {
            if timerEngine.isPaused {
                timerEngine.resume()
                rescheduleCompletionNotification()
            } else {
                timerEngine.pause()
                NotificationService.shared.cancelTimerCompletion()
            }
        } label: {
            Image(systemName: timerEngine.isPaused ? "play.fill" : "pause.fill")
                .font(.title3)
                .foregroundColor(.secondary)
                .padding(20)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
        }
        .accessibilityLabel(timerEngine.isPaused ? "Resume timer" : "Pause timer")
    }

    // MARK: - Pause Indicator

    private var pauseIndicator: some View {
        VStack {
            Spacer()
            Text("Paused")
                .font(.title3)
                .fontWeight(.light)
                .foregroundColor(.secondary)
                .padding(.vertical, 8)
                .padding(.horizontal, 24)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
            Spacer()
        }
    }

    // MARK: - Completion & External Surfaces

    private func handleCompletion() {
        UIApplication.shared.isIdleTimerDisabled = false
        NotificationService.shared.cancelTimerCompletion()
        WidgetDataProvider.shared.markInactive()
        LiveActivityManager.shared.endActivity()

        if !appSettings.completionFeedbackIsSilent(isPro: proUnlock.isPro) {
            HapticService.shared.playFinishHaptic()
            if proUnlock.isPro && appSettings.sunriseHapticsEnabled {
                HapticService.shared.playSunriseHaptic()
            }
        }

        recordSession()
        withAnimation(.easeInOut(duration: 1.0)) {
            showCompletion = true
        }
    }

    private func updateExternalSurfaces(progress: Double) {
        let now = Date()
        guard progress >= 1 || now.timeIntervalSince(lastExternalSurfaceUpdate) >= 5 else { return }
        lastExternalSurfaceUpdate = now

        WidgetDataProvider.shared.update(
            progress: progress,
            remaining: timerEngine.remaining,
            themeID: theme.id
        )

        if appSettings.liveActivitiesEnabled {
            LiveActivityManager.shared.updateActivity(progress: progress, remaining: timerEngine.remaining)
        }
    }

    private func rescheduleCompletionNotification() {
        guard appSettings.completionNotificationsEnabled else { return }
        Task {
            await NotificationService.shared.scheduleTimerCompletion(
                after: timerEngine.remaining,
                themeName: theme.name,
                silent: appSettings.completionFeedbackIsSilent(isPro: proUnlock.isPro)
            )
        }
    }

    // MARK: - Session Recording

    private var currentSession: TimerSession {
        TimerSession(
            startDate: timerEngine.startDate ?? Date(),
            endDate: Date(),
            duration: timerEngine.totalDuration,
            actualDuration: timerEngine.activeElapsed,
            themeID: theme.id,
            completedNormally: true
        )
    }

    private func recordSession() {
        analytics.recordSession(currentSession)
    }
}
