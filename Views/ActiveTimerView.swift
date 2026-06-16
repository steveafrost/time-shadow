import SwiftUI

// MARK: - ActiveTimerView

/// Full-screen view during an active timer.
/// Wallpaper visible behind a translucent gradient overlay;
/// the shadow creeps across from left to right.
/// No numbers, just ambient awareness.
struct ActiveTimerView: View {
    @EnvironmentObject private var timerEngine: TimerEngine
    @EnvironmentObject private var proUnlock: ProUnlockManager
    @EnvironmentObject private var analytics: AnalyticsService

    @Binding var theme: ShadowTheme
    let onDismiss: () -> Void

    @State private var showCompletion = false
    @State private var showPauseOverlay = false

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
                    // Cancel button
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
                    .padding(.leading, 24)

                    Spacer()

                    // Pause/Resume button
                    Button {
                        if timerEngine.isPaused {
                            timerEngine.resume()
                        } else {
                            timerEngine.pause()
                        }
                    } label: {
                        Image(systemName: timerEngine.isPaused ? "play.fill" : "pause.fill")
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .padding(20)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 24)
                }
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            // Wire up completion callback
            timerEngine.onComplete = { [self] in
                HapticService.shared.playFinishHaptic()
                if proUnlock.isPro {
                    HapticService.shared.playSunriseHaptic()
                }
                recordSession()
                withAnimation(.easeInOut(duration: 1.0)) {
                    showCompletion = true
                }
            }
        }
        .onChange(of: timerEngine.progress) { newProgress in
            WidgetDataProvider.shared.update(
                progress: newProgress,
                remaining: timerEngine.remaining,
                themeID: theme.id
            )
        }
        .statusBar(hidden: true)
        .preferredColorScheme(.dark)
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
        let session = TimerSession(
            startDate: timerEngine.startDate ?? Date(),
            endDate: Date(),
            duration: timerEngine.totalDuration,
            actualDuration: timerEngine.activeElapsed,
            themeID: theme.id,
            completedNormally: true
        )
        analytics.recordSession(session)
    }
}
