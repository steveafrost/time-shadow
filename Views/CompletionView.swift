import SwiftUI

// MARK: - CompletionView

/// Gentle screen pulse animation + haptic on timer completion.
/// Shows "Done" with a timer summary (no precise numbers in line with ethos).
struct CompletionView: View {
    let session: TimerSession
    let onDismiss: () -> Void

    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.0
    @State private var pulse = false

    var body: some View {
        ZStack {
            // Gentle pulsing background
            Color(.systemBackground)
                .opacity(0.3 * opacity)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // Checkmark circle
                ZStack {
                    Circle()
                        .stroke(Color.green.opacity(0.6), lineWidth: pulse ? 3 : 1)
                        .frame(width: 100, height: 100)
                        .scaleEffect(pulse ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulse)

                    Image(systemName: "checkmark")
                        .font(.system(size: 40, weight: .light))
                        .foregroundColor(.green)
                }

                Text("Done")
                    .font(.largeTitle)
                    .fontWeight(.light)
                    .foregroundColor(.primary)

                Text("Your session is complete.")
                    .font(.body)
                    .foregroundColor(.secondary)

                Text("A shadow has passed.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()

                Spacer()

                // Dismiss button
                Button {
                    onDismiss()
                } label: {
                    Text("Continue")
                        .font(.body)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.horizontal, 32)
                }
                .buttonStyle(.plain)

                Spacer()
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                pulse = true
            }
        }
    }
}
