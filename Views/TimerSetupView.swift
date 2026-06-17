import SwiftUI

// MARK: - TimerSetupView

/// Main setup screen: preset picker, theme preview, and start button.
struct TimerSetupView: View {
    @EnvironmentObject private var proUnlock: ProUnlockManager
    @EnvironmentObject private var storeKit: StoreKitManager

    @Binding var selectedTheme: ShadowTheme
    let onStart: (TimeInterval) -> Void

    @State private var selectedPreset: TimerPreset? = TimerPreset.defaultPresets[0]
    @State private var customMinutes: Double = 25
    @State private var showCustomPicker = false
    @State private var showThemePicker = false
    @State private var showSettings = false
    @State private var showStats = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {

                    // MARK: - Header
                    VStack(spacing: 4) {
                        Text("Time Shadow")
                            .font(.largeTitle)
                            .fontWeight(.light)
                            .foregroundColor(.primary)
                        Text("Watch the shadow grow")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)

                    // MARK: - Preset Grid
                    PresetPickerView(selectedPreset: $selectedPreset,
                                     customMinutes: $customMinutes,
                                     showCustomPicker: $showCustomPicker)

                    // MARK: - Theme Preview
                    VStack(spacing: 12) {
                        HStack {
                            Text("Shadow Color")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Spacer()
                            if selectedTheme.isPro && !proUnlock.isPro {
                                Image(systemName: "lock.fill")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }

                        // Preview gradient bar
                        RoundedRectangle(cornerRadius: 12)
                            .fill(LinearGradient(
                                gradient: Gradient(colors: selectedTheme.gradientColors),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(height: 48)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                            )

                        Button {
                            showThemePicker = true
                        } label: {
                            HStack {
                                Text(selectedTheme.name)
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                            }
                            .font(.subheadline)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal)

                    // MARK: - Start Button
                    VStack(spacing: 8) {
                        Button {
                            normalizeThemeForCurrentUnlockState()
                            onStart(selectedDuration)
                        } label: {
                            Text("Start")
                                .font(.title2)
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(.tint)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .tint(.primary)
                        .padding(.horizontal)

                        Text("Tap Start to let the shadow creep across your wallpaper.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }

                    Spacer(minLength: 40)
                }
            }
            .scrollIndicators(.hidden)
            .background(Color(.systemBackground))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showStats = true
                    } label: {
                        Image(systemName: "chart.bar.fill")
                            .font(.body)
                    }
                    .tint(.secondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.body)
                    }
                    .tint(.secondary)
                }
            }
            .sheet(isPresented: $showThemePicker) {
                ThemePickerView(selectedTheme: $selectedTheme)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showStats) {
                StatsView()
            }
            .sheet(isPresented: $showCustomPicker) {
                customDurationSheet
            }
            .onAppear(perform: normalizeThemeForCurrentUnlockState)
            .onChange(of: proUnlock.isPro) { _, _ in
                normalizeThemeForCurrentUnlockState()
            }
        }
    }

    private var selectedDuration: TimeInterval {
        guard let selectedPreset else { return customMinutes * 60 }
        if selectedPreset.name == "Custom" {
            return customMinutes * 60
        }
        return selectedPreset.duration
    }

    private func normalizeThemeForCurrentUnlockState() {
        if selectedTheme.isPro && !proUnlock.isPro {
            selectedTheme = .warmGray
        }
    }

    // MARK: - Custom Duration Sheet

    private var customDurationSheet: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Custom Duration")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("\(Int(customMinutes)) min")
                    .font(.system(size: 56, weight: .light, design: .rounded))
                    .foregroundColor(.primary)
                    .contentTransition(.numericText())

                Slider(value: $customMinutes, in: proUnlock.isPro ? 5...240 : 1...25, step: 1)
                    .padding(.horizontal)

                if customMinutes > 25 && !proUnlock.isPro {
                    Label("Upgrade to Pro for longer durations", systemImage: "lock.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                }

                Button("Set Duration") {
                    showCustomPicker = false
                }
                .buttonStyle(.borderedProminent)
                .tint(.primary)
            }
            .padding(32)
            .presentationDetents([.height(320)])
        }
    }
}
