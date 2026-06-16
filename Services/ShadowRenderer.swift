import SwiftUI

// MARK: - ShadowRenderer

/// Renders the ambient shadow gradient that creeps across the screen.
/// Uses a SwiftUI `LinearGradient` with an animatable offset driven by timer progress.
struct ShadowRenderer: View {
    let progress: Double          // 0.0 – 1.0
    let theme: ShadowTheme
    let isActive: Bool

    // Fraction of screen width that the gradient band covers
    private let bandWidth: CGFloat = 0.35

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let band = w * bandWidth
            // The leading edge of the gradient band: starts negative (offscreen left)
            // and moves to the right over the duration.
            let offset = -band + (w + band) * progress

            LinearGradient(
                gradient: Gradient(colors: theme.gradientColors),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: band)
            .offset(x: offset)
            .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.8), value: offset)
        }
        .allowsHitTesting(false)
    }
}

// MARK: - ShadowOverlay

/// A translucent overlay that sits above the wallpaper and below the gradient.
/// The gradient edge itself gets the color; the rest is clear so wallpaper shows through.
struct ShadowOverlay: View {
    let progress: Double
    let theme: ShadowTheme
    let isActive: Bool

    var body: some View {
        ZStack {
            // Very subtle overall dim that increases with progress
            Color.black
                .opacity(isActive ? 0.03 * progress : 0.0)

            // The moving gradient band
            ShadowRenderer(progress: progress, theme: theme, isActive: isActive)
        }
        .ignoresSafeArea()
    }
}
