import SwiftUI

// MARK: - ThemePickerView

/// Scrollable grid of theme preview circles.
/// Locked themes show a Pro badge.
struct ThemePickerView: View {
    @EnvironmentObject private var proUnlock: ProUnlockManager
    @EnvironmentObject private var storeKit: StoreKitManager

    @Binding var selectedTheme: ShadowTheme
    @Environment(\.dismiss) private var dismiss

    private let themes = ShadowTheme.allCases

    private let columns = [
        GridItem(.adaptive(minimum: 80, maximum: 100), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Text("Choose a shadow color")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(themes) { theme in
                            themeButton(theme)
                        }
                    }
                    .padding(.horizontal)

                    if !proUnlock.isPro {
                        VStack(spacing: 8) {
                            Text("Unlock all 12 themes with Pro")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            NavigationLink {
                                ProUpgradeView()
                            } label: {
                                Text("Upgrade • $3.99")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 10)
                                    .background(.tint)
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                            }
                            .tint(.primary)
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(.vertical, 24)
            }
            .scrollIndicators(.hidden)
            .navigationTitle("Themes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private func themeButton(_ theme: ShadowTheme) -> some View {
        let isSelected = selectedTheme.id == theme.id
        let isLocked = theme.isPro && !proUnlock.isPro

        Button {
            if isLocked { return }
            selectedTheme = theme
            dismiss()
        } label: {
            VStack(spacing: 6) {
                // Preview circle
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: theme.gradientColors),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Circle()
                            .stroke(isSelected ? Color.primary : Color.clear, lineWidth: 2.5)
                    )
                    .overlay(
                        Group {
                            if isLocked {
                                Image(systemName: "lock.fill")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                                    .shadow(radius: 2)
                            } else if isSelected {
                                Image(systemName: "checkmark")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                                    .shadow(radius: 2)
                            }
                        }
                    )

                Text(theme.name)
                    .font(.caption2)
                    .foregroundColor(isLocked ? .secondary : .primary)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
        .opacity(isLocked ? 0.5 : 1.0)
    }
}
