import SwiftUI

// MARK: - ProUpgradeView

/// One-time $3.99 Pro purchase screen.
/// Shows feature comparison and purchase button.
struct ProUpgradeView: View {
    @EnvironmentObject private var storeKit: StoreKitManager
    @EnvironmentObject private var proUnlock: ProUnlockManager
    @Environment(\.dismiss) private var dismiss

    @State private var showRestoreAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                // MARK: - Header
                VStack(spacing: 8) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.yellow)
                        .padding(.top, 24)

                    Text("Time Shadow Pro")
                        .font(.largeTitle)
                        .fontWeight(.light)

                    Text("One-time purchase • $3.99")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                // MARK: - Features
                VStack(spacing: 16) {
                    featureRow(icon: "clock.badge.checkmark",
                               title: "Any Duration",
                               detail: "From 5 minutes to 4 hours")
                    featureRow(icon: "paintpalette.fill",
                               title: "12 Shadow Themes",
                               detail: "Sunset, Ocean, Aurora, and more")
                    featureRow(icon: "iphone.gen3.radiowaves.left.and.right",
                               title: "Live Activities",
                               detail: "Dynamic Island progress bar")
                    featureRow(icon: "square.resize.up",
                               title: "Lock Screen Widget",
                               detail: "See your timer at a glance")
                    featureRow(icon: "hand.point.up.braille",
                               title: "Sunrise Haptic Alarm",
                               detail: "Gentle escalating wake-up feel")
                    featureRow(icon: "chart.bar.fill",
                               title: "Focus Stats History",
                               detail: "Track your deep work over time")
                    featureRow(icon: "moon.stars.fill",
                               title: "Zen Mode",
                               detail: "Complete silence on completion")
                    featureRow(icon: "square.on.square.dashed",
                               title: "Multiple Presets",
                               detail: "Save your favorite durations")
                }
                .padding(.horizontal)

                Spacer(minLength: 20)

                // MARK: - Purchase Button
                if proUnlock.isPro {
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.green)
                        Text("Pro is already unlocked!")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else {
                    VStack(spacing: 12) {
                        Button {
                            Task {
                                await storeKit.purchasePro()
                            }
                        } label: {
                            HStack {
                                if storeKit.isPurchasing {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Unlock Pro • $3.99")
                                        .font(.title3)
                                        .fontWeight(.medium)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.primary)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .disabled(storeKit.isPurchasing)
                        .padding(.horizontal)

                        Button {
                            Task {
                                await storeKit.restorePurchases()
                                showRestoreAlert = true
                            }
                        } label: {
                            Text("Restore Purchases")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        if let error = storeKit.purchaseError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.bottom, 32)
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Pro")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Restore Purchases", isPresented: $showRestoreAlert) {
            Button("OK") {}
        } message: {
            if proUnlock.isPro {
                Text("Pro has been restored successfully!")
            } else {
                Text("No previous Pro purchase was found.")
            }
        }
    }

    // MARK: - Feature Row

    private func featureRow(icon: String, title: String, detail: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.primary)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                Text(detail)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}
