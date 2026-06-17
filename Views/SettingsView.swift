import SwiftUI
import UserNotifications

// MARK: - SettingsView

/// App settings: Pro unlock, physical-device behavior, about, etc.
struct SettingsView: View {
    @EnvironmentObject private var proUnlock: ProUnlockManager
    @EnvironmentObject private var storeKit: StoreKitManager
    @EnvironmentObject private var appSettings: AppSettings
    @EnvironmentObject private var notificationService: NotificationService
    @Environment(\.dismiss) private var dismiss

    @State private var showNotificationDeniedAlert = false

    var body: some View {
        NavigationStack {
            List {
                proSection
                timerBehaviorSection
                aboutSection
                privacySection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .task {
                await notificationService.refreshAuthorizationStatus()
            }
            .onChange(of: appSettings.completionNotificationsEnabled) { _, enabled in
                guard enabled else {
                    NotificationService.shared.cancelTimerCompletion()
                    return
                }
                Task {
                    let granted = await notificationService.requestAuthorizationIfNeeded()
                    if !granted {
                        appSettings.completionNotificationsEnabled = false
                        showNotificationDeniedAlert = true
                    }
                }
            }
            .alert("Notifications are off", isPresented: $showNotificationDeniedAlert) {
                Button("OK") {}
            } message: {
                Text("Enable notifications in iOS Settings if you want Time Shadow to alert you when a timer finishes in the background.")
            }
        }
    }

    // MARK: - Sections

    private var proSection: some View {
        Section {
            if proUnlock.isPro {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("Pro Unlocked")
                        .font(.body)
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            } else {
                NavigationLink {
                    ProUpgradeView()
                } label: {
                    HStack {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.orange)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Upgrade to Pro")
                                .font(.body)
                            Text("Unlock all themes, durations & more")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        } header: {
            Text("Time Shadow Pro")
        }
    }

    private var timerBehaviorSection: some View {
        Section {
            Toggle(isOn: $appSettings.completionNotificationsEnabled) {
                Label("Finish Notifications", systemImage: "bell.badge")
            }

            Toggle(isOn: $appSettings.keepScreenAwakeEnabled) {
                Label("Keep Screen Awake", systemImage: "iphone.gen3")
            }

            Toggle(isOn: $appSettings.liveActivitiesEnabled) {
                Label("Live Activities", systemImage: "iphone.gen3.radiowaves.left.and.right")
            }

            Toggle(isOn: $appSettings.sunriseHapticsEnabled) {
                Label("Sunrise Haptics", systemImage: "hand.point.up.braille")
            }
            .disabled(!proUnlock.isPro || appSettings.zenModeEnabled)

            Toggle(isOn: $appSettings.zenModeEnabled) {
                HStack {
                    Label("Zen Mode", systemImage: "moon.stars.fill")
                    if !proUnlock.isPro {
                        Spacer()
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
            .disabled(!proUnlock.isPro)

            if !proUnlock.isPro {
                NavigationLink("Unlock Zen Mode and haptics") {
                    ProUpgradeView()
                }
                .font(.caption)
            }
        } header: {
            Text("Timer Behavior")
        } footer: {
            Text("Notifications make long timers reliable when the app is backgrounded. Zen Mode keeps completion silent for quiet rooms.")
        }
    }

    private var aboutSection: some View {
        Section {
            HStack {
                Text("Version")
                Spacer()
                Text("1.0.0")
                    .foregroundColor(.secondary)
            }

            Link(destination: URL(string: "https://straightcodes.com")!) {
                HStack {
                    Text("Website")
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Link(destination: URL(string: "https://github.com/steveafrost/time-shadow")!) {
                HStack {
                    Text("GitHub")
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        } header: {
            Text("About")
        }
    }

    private var privacySection: some View {
        Section {
            Text("Time Shadow is a minimal ambient timer. No data is collected or shared. Timer history, preferences, and purchase state stay on device or in Apple-managed App Store systems.")
                .font(.caption)
                .foregroundColor(.secondary)
        } header: {
            Text("Privacy")
        }
    }
}
