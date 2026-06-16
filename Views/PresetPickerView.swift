import SwiftUI

// MARK: - PresetPickerView

/// Grid of timer presets. Shows a selection ring around the chosen one.
/// Pro presets are locked for free users.
struct PresetPickerView: View {
    @EnvironmentObject private var proUnlock: ProUnlockManager

    @Binding var selectedPreset: TimerPreset?
    @Binding var customMinutes: Double
    @Binding var showCustomPicker: Bool

    private let presets = TimerPreset.defaultPresets

    private let columns = [
        GridItem(.adaptive(minimum: 90, maximum: 110), spacing: 12)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Duration")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(presets) { preset in
                    presetButton(preset)
                }
            }
            .padding(.horizontal)
        }
    }

    @ViewBuilder
    private func presetButton(_ preset: TimerPreset) -> some View {
        let isSelected = selectedPreset?.id == preset.id
        let isLocked = preset.isPro && !proUnlock.isPro

        Button {
            if isLocked {
                // Let the system show Pro upgrade via the ProUpgradeView
                return
            }
            selectedPreset = preset
            if preset.name == "Custom" {
                showCustomPicker = true
            }
        } label: {
            VStack(spacing: 4) {
                if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                }

                Text(preset.name)
                    .font(.callout)
                    .fontWeight(isSelected ? .medium : .regular)

                Text(preset.formattedShort)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color(.tertiarySystemBackground) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.primary : Color.clear, lineWidth: 1.5)
                    )
            )
            .opacity(isLocked ? 0.6 : 1.0)
        }
        .buttonStyle(.plain)
        .disabled(isLocked)
    }
}
